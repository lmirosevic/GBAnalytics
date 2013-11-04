#import "TSCore.h"
#import "TSHelpers.h"
#import "TSLogging.h"

#define kTSVersion @"2.3"
#define kTSEventUrlTemplate @"https://api.tapstream.com/%@/event/%@/"
#define kTSHitUrlTemplate @"http://api.tapstream.com/%@/hit/%@.gif"

@interface TSEvent(hidden)
- (void)firing;
@end




@interface TSCore()

@property(nonatomic, STRONG_OR_RETAIN) id<TSDelegate> del;
@property(nonatomic, STRONG_OR_RETAIN) id<TSPlatform> platform;
@property(nonatomic, STRONG_OR_RETAIN) id<TSCoreListener> listener;
@property(nonatomic, STRONG_OR_RETAIN) TSConfig *config;
@property(nonatomic, STRONG_OR_RETAIN) NSString *accountName;
@property(nonatomic, STRONG_OR_RETAIN) NSMutableString *postData;
@property(nonatomic, STRONG_OR_RETAIN) NSMutableSet *firingEvents;
@property(nonatomic, STRONG_OR_RETAIN) NSMutableSet *firedEvents;
@property(nonatomic, STRONG_OR_RETAIN) NSString *failingEventId;

- (NSString *)clean:(NSString *)s;
- (void)increaseDelay;
- (void)appendPostPairWithKey:(NSString *)key value:(NSString *)value;
- (void)makePostArgsWithSecret:(NSString *)secret;
@end


@implementation TSCore

@synthesize del, platform, listener, config, accountName, postData, firingEvents, firedEvents, failingEventId;

- (id)initWithDelegate:(id<TSDelegate>)delegateVal
	platform:(id<TSPlatform>)platformVal
	listener:(id<TSCoreListener>)listenerVal
	accountName:(NSString *)accountNameVal
	developerSecret:(NSString *)developerSecretVal
	config:(TSConfig *)configVal
{
	if((self = [super init]) != nil)
	{
		self.del = delegateVal;
		self.platform = platformVal;
		self.listener = listenerVal;
		self.config = configVal;
		self.accountName = [self clean:accountNameVal];
		self.postData = nil;
		self.failingEventId = nil;

		[self makePostArgsWithSecret:developerSecretVal];

		self.firingEvents = [[NSMutableSet alloc] initWithCapacity:32];
		self.firedEvents = [platform loadFiredEvents];
	}
	return self;
}

- (void)dealloc
{
	RELEASE(del);
	RELEASE(platform);
	RELEASE(listener);
	RELEASE(accountName);
	RELEASE(postData);
	RELEASE(firingEvents);
	RELEASE(firedEvents);
	RELEASE(failingEventId);
	SUPER_DEALLOC;
}

- (void)start
{
#if TEST_IOS || TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
	NSString *platformName = @"ios";
#else
	NSString *platformName = @"mac";
#endif

	NSString *appName = [platform getAppName];
	if(appName == nil)
	{
		appName = @"";
	}

	if(config.fireAutomaticInstallEvent)
	{
		if(config.installEventName != nil)
		{
			[self fireEvent:[TSEvent eventWithName:config.installEventName oneTimeOnly:YES]];
		}
		else
		{
			NSString *eventName = [NSString stringWithFormat:@"%@-%@-install", platformName, appName];
			[self fireEvent:[TSEvent eventWithName:eventName oneTimeOnly:YES]];
		}
	}

	if(config.fireAutomaticOpenEvent)
	{
		if(config.openEventName != nil)
		{
			[self fireEvent:[TSEvent eventWithName:config.openEventName oneTimeOnly:NO]];
		}
		else
		{
			NSString *eventName = [NSString stringWithFormat:@"%@-%@-open", platformName, appName];
			[self fireEvent:[TSEvent eventWithName:eventName oneTimeOnly:NO]];
		}
	}
}

- (void)fireEvent:(TSEvent *)e
{
	@synchronized(self)
	{
		// Notify the event that we are going to fire it so it can record the time
		[e firing];

		if(e.oneTimeOnly)
		{
			if([firedEvents containsObject:e.name])
			{
				[TSLogging logAtLevel:kTSLoggingInfo format:@"Tapstream ignoring event named \"%@\" because it is a one-time-only event that has already been fired", e.name];
				[listener reportOperation:@"event-ignored-already-fired" arg:e.name];
				[listener reportOperation:@"job-ended" arg:e.name];
				return;
			}
			else if([firingEvents containsObject:e.name])
			{
				[TSLogging logAtLevel:kTSLoggingInfo format:@"Tapstream ignoring event named \"%@\" because it is a one-time-only event that is already in progress", e.name];
				[listener reportOperation:@"event-ignored-already-in-progress" arg:e.name];
				[listener reportOperation:@"job-ended" arg:e.name];
				return;
			}

			[firingEvents addObject:e.name];
		}

		NSString *url = [NSString stringWithFormat:kTSEventUrlTemplate, accountName, e.encodedName];
		NSString *data = [postData stringByAppendingString:e.postData];


		int actualDelay = [del getDelay];
		dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * actualDelay);
		dispatch_after(dispatchTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

			TSResponse *response = [platform request:url data:data];
			bool failed = response.status < 200 || response.status >= 300;
			bool shouldRetry = response.status < 0 || (response.status >= 500 && response.status < 600);

			@synchronized(self)
			{
				if(e.oneTimeOnly)
				{
					[firingEvents removeObject:e.name];
				}

				if(failed)
				{
					// Only increase delays if we actually intend to retry the event
					if(shouldRetry)
					{
						// Not every job that fails will increase the retry delay.  It will be the responsibility of
						// the first failed job to increase the delay after every failure.
						if(delay == 0)
						{
							// This is the first job to fail, it must be the one to manage delay timing
							self.failingEventId = e.uid;
							[self increaseDelay];
						}
						else if([failingEventId isEqualToString:e.uid])
						{
							[self increaseDelay];
						}
					}
				}
				else
				{
					if(e.oneTimeOnly)
					{
						[firedEvents addObject:e.name];

						[platform saveFiredEvents:firedEvents];
						[listener reportOperation:@"fired-list-saved" arg:e.name];
					}

					// Success of any event resets the delay
					delay = 0;
				}
			}

			if(failed)
			{
				if(response.status < 0)
				{
					[TSLogging logAtLevel:kTSLoggingError format:@"Tapstream Error: Failed to fire event, error=%@", response.message];
				}
				else if(response.status == 404)
				{
					[TSLogging logAtLevel:kTSLoggingError format:@"Tapstream Error: Failed to fire event, http code %d\nDoes your event name contain characters that are not url safe? This event will not be retried.", response.status];
				}
				else if(response.status == 403)
				{
				   [TSLogging logAtLevel:kTSLoggingError format:@"Tapstream Error: Failed to fire event, http code %d\nAre your account name and application secret correct?  This event will not be retried.", response.status];
				}
				else
				{
					NSString *retryMsg = @"";
					if(!shouldRetry)
					{
						retryMsg = @"  This event will not be retried.";
					}
					[TSLogging logAtLevel:kTSLoggingError format:@"Tapstream Error: Failed to fire event, http code %d.%@", response.status, retryMsg];
				}

				[listener reportOperation:@"event-failed" arg:e.name];
				if(shouldRetry)
				{
					[listener reportOperation:@"retry" arg:e.name];
					[listener reportOperation:@"job-ended" arg:e.name];
					if([del isRetryAllowed])
					{
						[self fireEvent:e];
					}
					return;
				}
			}
			else
			{
				[TSLogging logAtLevel:kTSLoggingInfo format:@"Tapstream fired event named \"%@\"", e.name];
				[listener reportOperation:@"event-succeeded" arg:e.name];
			}
		
			[listener reportOperation:@"job-ended" arg:e.name];
		});
	}
}

- (void)fireHit:(TSHit *)hit completion:(void(^)(TSResponse *))completion
{
	NSString *url = [NSString stringWithFormat:kTSHitUrlTemplate, accountName, hit.encodedTrackerName];
	NSString *data = hit.postData;

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		TSResponse *response = [platform request:url data:data];
		if(response.status < 200 || response.status >= 300)
		{
			[TSLogging logAtLevel:kTSLoggingError format:@"Tapstream Error: Failed to fire hit, http code: %d", response.status];
			[listener reportOperation:@"hit-failed"];
		}
		else
		{
			[TSLogging logAtLevel:kTSLoggingInfo format:@"Tapstream fired hit to tracker: %@", hit.trackerName];
			[listener reportOperation:@"hit-succeeded"];
		}

		if(completion != nil)
		{
			completion(response);
		}
	});
}

- (int)getDelay
{
	return delay;
}

- (NSString *)encodeString:(NSString *)s
{
	return AUTORELEASE((BRIDGE_TRANSFER NSString *)CFURLCreateStringByAddingPercentEscapes(
		NULL, (CFStringRef)s, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}

- (NSString *)clean:(NSString *)s
{
	s = [s lowercaseString];
	s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return [self encodeString:s];
}

- (void)increaseDelay
{
	if(delay == 0)
	{
		// First failure
		delay = 2;
	}
	else
	{
		// 2, 4, 8, 16, 32, 60, 60, 60...
		int newDelay = (int)pow( 2, log2( delay ) + 1 );
		delay = newDelay > 60 ? 60 : newDelay;
	}
	[listener reportOperation:@"increased-delay"];
}

- (void)appendPostPairWithKey:(NSString *)key value:(NSString *)value
{
	if(value == nil)
	{
		return;
	}

	if(postData == nil)
	{
		self.postData = [[NSMutableString alloc] initWithCapacity:256];
	}
	else
	{
		[postData appendString:@"&"];
	}
	[postData appendString:[self encodeString:key]];
	[postData appendString:@"="];
	[postData appendString:[self encodeString:value]];
}

- (void)makePostArgsWithSecret:(NSString *)secret
{
	[self appendPostPairWithKey:@"secret" value:secret];
	[self appendPostPairWithKey:@"sdkversion" value:kTSVersion];

	if(config.hardware != nil)
	{
		if([config.hardware length] > 255)
		{
			[TSLogging logAtLevel:kTSLoggingWarn format:@"Tapstream Warning: Hardware argument exceeds 255 characters, it will not be included with fired events"];
		}
		else
		{
			[self appendPostPairWithKey:@"hardware" value:config.hardware];
		}
	}

	if(config.odin1 != nil)
	{
		if([config.odin1 length] > 255)
		{
			[TSLogging logAtLevel:kTSLoggingWarn format:@"Tapstream Warning: ODIN-1 argument exceeds 255 characters, it will not be included with fired events"];
		}
		else
		{
			[self appendPostPairWithKey:@"hardware-odin1" value:config.odin1];
		}
	}

#if TEST_IOS || TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

	if(config.openUdid != nil)
	{
		if([config.openUdid length] > 255)
		{
			[TSLogging logAtLevel:kTSLoggingWarn format:@"Tapstream Warning: OpenUDID argument exceeds 255 characters, it will not be included with fired events"];
		}
		else
		{
			[self appendPostPairWithKey:@"hardware-open-udid" value:config.openUdid];
		}
	}

	if(config.udid != nil)
	{
		if([config.udid length] > 255)
		{
			[TSLogging logAtLevel:kTSLoggingWarn format:@"Tapstream Warning: UDID argument exceeds 255 characters, it will not be included with fired events"];
		}
		else
		{
			[self appendPostPairWithKey:@"hardware-ios-udid" value:config.udid];
		}
	}

	if(config.idfa != nil)
	{
		if([config.idfa length] > 255)
		{
			[TSLogging logAtLevel:kTSLoggingWarn format:@"Tapstream Warning: IDFA argument exceeds 255 characters, it will not be included with fired events"];
		}
		else
		{
			[self appendPostPairWithKey:@"hardware-ios-idfa" value:config.idfa];
		}
	}

	if(config.secureUdid != nil)
	{
		if([config.secureUdid length] > 255)
		{
			[TSLogging logAtLevel:kTSLoggingWarn format:@"Tapstream Warning: SecureUDID argument exceeds 255 characters, it will not be included with fired events"];
		}
		else
		{
			[self appendPostPairWithKey:@"hardware-ios-secure-udid" value:config.secureUdid];
		}
	}

#else

	if([config.serialNumber length] > 255)
	{
		[TSLogging logAtLevel:kTSLoggingWarn format:@"Tapstream Warning: Serial number argument exceeds 255 characters, it will not be included with fired events"];
	}
	else
	{
		[self appendPostPairWithKey:@"hardware-mac-serial-number" value:config.serialNumber];
	}

#endif



	if(config.collectWifiMac)
	{
		[self appendPostPairWithKey:@"hardware-wifi-mac" value:[platform getWifiMac]];
	}

	[self appendPostPairWithKey:@"uuid" value:[platform loadUuid]];

#if TEST_IOS || TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
	[self appendPostPairWithKey:@"platform" value:@"iOS"];
#else
	[self appendPostPairWithKey:@"platform" value:@"Mac"];
#endif

	[self appendPostPairWithKey:@"vendor" value:[platform getManufacturer]];
	[self appendPostPairWithKey:@"model" value:[platform getModel]];
	[self appendPostPairWithKey:@"os" value:[platform getOs]];
	[self appendPostPairWithKey:@"resolution" value:[platform getResolution]];
	[self appendPostPairWithKey:@"locale" value:[platform getLocale]];
	[self appendPostPairWithKey:@"app-name" value:[platform getAppName]];
	[self appendPostPairWithKey:@"package-name" value:[platform getPackageName]];

	NSString *offset = [NSString stringWithFormat:@"%d", (int)[[NSTimeZone systemTimeZone] secondsFromGMT]];
	[self appendPostPairWithKey:@"gmtoffset" value:offset];
}


@end