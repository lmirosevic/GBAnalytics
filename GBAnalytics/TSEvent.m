#import "TSEvent.h"
#import <sys/time.h>
#import <stdio.h>
#import <stdlib.h>
#import "TSLogging.h"

@interface TSEvent()

- (id)initWithName:(NSString *)name oneTimeOnly:(BOOL)oneTimeOnly;
- (void)firing;
- (NSString *)makeUid;

@end



@implementation TSEvent

@synthesize uid, name, encodedName, oneTimeOnly, postData;

+ (id)eventWithName:(NSString *)eventName oneTimeOnly:(BOOL)oneTimeOnlyArg
{
	return AUTORELEASE([[self alloc] initWithName:eventName oneTimeOnly:oneTimeOnlyArg]);
}

- (id)initWithName:(NSString *)eventName oneTimeOnly:(BOOL)oneTimeOnlyArg
{
	if((self = [super init]) != nil)
	{
		firstFiredTime = 0;
		uid = RETAIN([self makeUid]);
		name = RETAIN([[eventName lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
		encodedName = RETAIN([self encodeString:name]);
		oneTimeOnly = oneTimeOnlyArg;
	}
	return self;
}

- (NSString *)encodeString:(NSString *)s
{
	return AUTORELEASE((BRIDGE_TRANSFER NSString *)CFURLCreateStringByAddingPercentEscapes(
		NULL, (CFStringRef)s, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}

- (void)addValue:(NSString *)value forKey:(NSString *)key
{
	if(value == nil)
	{
		return;
	}

	if(key.length > 255)
	{
		[TSLogging logAtLevel:kTSLoggingWarn format:@"Tapstream Warning: Custom key exceeds 255 characters, this field will not be included in the post (key=%@)", key];
		return;
	}
	NSString *encodedKey = [self encodeString:[@"custom-" stringByAppendingString:key]];

	NSString *encodedValue = [self encodeString:value];
	if(encodedValue.length > 255)
	{
		[TSLogging logAtLevel:kTSLoggingWarn format:@"Tapstream Warning: Custom value exceeds 255 characters, this field will not be included in the post (value=%@)", value];
		return;
	}

	if(postData == nil)
	{
		postData = RETAIN([NSMutableString stringWithCapacity:64]);
	}
	[postData appendString:@"&"];
	[postData appendString:encodedKey];
	[postData appendString:@"="];
	[postData appendString:encodedValue];
}

- (void)addIntegerValue:(int)value forKey:(NSString *)key
{
	[self addValue:[NSString stringWithFormat:@"%d", value] forKey:key];
}

- (void)addUnsignedIntegerValue:(uint)value forKey:(NSString *)key
{
	[self addValue:[NSString stringWithFormat:@"%u", value] forKey:key];
}

- (void)addDoubleValue:(double)value forKey:(NSString *)key
{
	[self addValue:[NSString stringWithFormat:@"%g", value] forKey:key];
}

- (void)addBooleanValue:(BOOL)value forKey:(NSString *)key
{
	[self addValue:(value ? @"true" : @"false") forKey:key];
}

- (NSString *)postData
{
	NSString *data = postData != nil ? (NSString *)postData : @"";
	return [[NSString stringWithFormat:@"&created=%u", (unsigned int)firstFiredTime] stringByAppendingString:data];
}

- (void)firing
{
	// Only record the time of the first fire attempt
	if(firstFiredTime == 0)
	{
		firstFiredTime = [[NSDate date] timeIntervalSince1970];
	}
}

- (NSString *)makeUid
{
	struct timeval time;
	gettimeofday(&time, NULL);
	long millis = (time.tv_sec * 1000) + (time.tv_usec / 1000);

	return [NSString stringWithFormat:@"%ld:%f", millis, rand() / (float)RAND_MAX];
}

- (void)dealloc
{
	RELEASE(uid);
	RELEASE(name);
	RELEASE(encodedName);
	RELEASE(postData);
	SUPER_DEALLOC;
}

@end