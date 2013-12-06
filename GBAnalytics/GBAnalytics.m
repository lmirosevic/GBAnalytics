//
//  GBAnalytics.m
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import "GBAnalytics.h"

#import <GBToolbox/GBToolbox.h>

#import "GBAnalytics_OpenUDID.h"
#import <AdSupport/AdSupport.h>

static NSString * const kGBAnalyticsCredentialsGoogleAnalyticsTrackingID = @"kGBAnalyticsCredentialsGoogleAnalyticsTrackingID";
static NSString * const kGBAnalyticsCredentialsFlurryAPIKey = @"kGBAnalyticsCredentialsFlurryAPIKey";
static NSString * const kGBAnalyticsCredentialsCrashlyticsAPIKey = @"kGBAnalyticsCredentialsCrashlyticsAPIKey";
static NSString * const kGBAnalyticsCredentialsTapstreamAccountName = @"kGBAnalyticsCredentialsTapstreamAccountName";
static NSString * const kGBAnalyticsCredentialsTapstreamSDKSecret = @"kGBAnalyticsCredentialsTapstreamSDKSecret";

static NSString * const kGBAnalyticsGoogleAnalyticsActionlessEventActionString = @"Plain";

@interface GBAnalytics ()

@property (strong, nonatomic) NSMutableDictionary       *connectedAnalyticsNetworks;
@property (assign, nonatomic) BOOL                      isDebugLoggingEnabled;

@end


@implementation GBAnalytics

#pragma mark - Storage

_singleton(GBAnalytics, sharedAnalytics)
_lazy(NSMutableDictionary, connectedAnalyticsNetworks, _connectedAnalyticsNetworks)

#pragma mark - Initialiser

-(id)init {
    if (self = [super init]) {
        self.isDebugLoggingEnabled = NO;
    }
    
    return self;
}

#pragma mark - Public API (AppStore)

+(void)startSessionWithNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials, ... {
    if ([self isDebugEnabled]) [self _debugLogSessionStartWithNetwork:network];
    
    //don't send data if debugging
    #if !DEBUG
        void(^invalidCredentialsErrorHandler)(void) = ^{
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"GBAnalytics Error: Didn't pass valid credentials for %@", [self _networkNameForNetwork:network]] userInfo:nil];
        };
    
        va_list args;
        va_start(args, credentials);

        switch (network) {
            case GBAnalyticsNetworkGoogleAnalytics: {
                if (IsValidString(credentials)) {
                    [GBAnalytics sharedAnalytics].connectedAnalyticsNetworks[@(GBAnalyticsNetworkGoogleAnalytics)] = @{kGBAnalyticsCredentialsGoogleAnalyticsTrackingID: credentials};
                    
                    [GAI sharedInstance].dispatchInterval = 5;
                    [GAI sharedInstance].trackUncaughtExceptions = NO;
                    [[GAI sharedInstance] trackerWithTrackingId:credentials];
                }
                else invalidCredentialsErrorHandler();
            } break;
                
            case GBAnalyticsNetworkFlurry: {
                if (IsValidString(credentials)) {
                    [GBAnalytics sharedAnalytics].connectedAnalyticsNetworks[@(GBAnalyticsNetworkFlurry)] = @{kGBAnalyticsCredentialsFlurryAPIKey: credentials};
                    
                    [Flurry startSession:credentials];
                }
                else invalidCredentialsErrorHandler();
            } break;
                
            case GBAnalyticsNetworkCrashlytics: {
                if (IsValidString(credentials)) {
                    [GBAnalytics sharedAnalytics].connectedAnalyticsNetworks[@(GBAnalyticsNetworkCrashlytics)] = @{kGBAnalyticsCredentialsCrashlyticsAPIKey: credentials};
                    
                    [Crashlytics startWithAPIKey:credentials];
                }
                else invalidCredentialsErrorHandler();
            } break;
                
            case GBAnalyticsNetworkTapstream: {
                NSString *AccountName = credentials;
                NSString *SDKSecret = va_arg(args, NSString *);
                
                if (IsValidString(AccountName) && IsValidString(SDKSecret)) {
                    [GBAnalytics sharedAnalytics].connectedAnalyticsNetworks[@(GBAnalyticsNetworkTapstream)] = @{kGBAnalyticsCredentialsTapstreamAccountName: AccountName, kGBAnalyticsCredentialsTapstreamSDKSecret: SDKSecret};
                    
                    [TSLogging setLogger:nil];
                    TSConfig *config = [TSConfig configWithDefaults];
                    config.openUdid = [OpenUDID value];
                    if (IsClassAvailable(ASIdentifierManager)) config.idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
                    [TSTapstream createWithAccountName:AccountName developerSecret:SDKSecret config:config];
                }
                else invalidCredentialsErrorHandler();
            } break;
                
            default: {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"GBAnalytics Error: Tried to connect to invalid network: %@", [self _networkNameForNetwork:network]] userInfo:nil];
            } break;
        }
        
        va_end(args);
    #endif
}

+(void)trackEvent:(NSString *)event {
    if ([self isDebugEnabled]) [self _debugLogEvent:event];

    //don't send data if debugging
    #if !DEBUG
        if (IsValidString(event)) {
            for (NSNumber *number in [GBAnalytics sharedAnalytics].connectedAnalyticsNetworks) {
                GBAnalyticsNetwork network = [number intValue];
                
                switch (network) {
                    case GBAnalyticsNetworkGoogleAnalytics: {
                        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:event action:kGBAnalyticsGoogleAnalyticsActionlessEventActionString label:nil value:nil] build]];
                    } break;
                        
                    case GBAnalyticsNetworkFlurry: {
                        [Flurry logEvent:event];
                    } break;
                        
                    case GBAnalyticsNetworkTapstream: {
                        [[TSTapstream instance] fireEvent:[TSEvent eventWithName:event oneTimeOnly:NO]];
                    } break;
                        
                    default:
                        break;
                }
            }
        }
        else {
            [self _debugErrorString:@"TrackEvent has not been called with a valid non-empty string"];
        }
    #endif
}

+(void)trackEvent:(NSString *)event withDictionary:(NSDictionary *)dictionary {
    if ([self isDebugEnabled]) [self _debugLogEvent:event withDictionary:dictionary];
    
    //don't send data if debugging
    #if !DEBUG
        if (IsValidString(event)) {
            //if the dictionary is not a dict or empty, just forward the call to the simple trackeEvent and thereby discard the event nonsense
            if (![dictionary isKindOfClass:[NSDictionary class]] || dictionary.count == 0) {
                [self trackEvent:event];
            }
            
            for (NSNumber *number in [GBAnalytics sharedAnalytics].connectedAnalyticsNetworks) {
                GBAnalyticsNetwork network = [number intValue];
                
                switch (network) {
                    case GBAnalyticsNetworkGoogleAnalytics: {
                        //for each key/value pair in the dict, send a separate event with a corresponding action/label pair
                        for (NSString *key in dictionary) {
                            [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:event action:key label:dictionary[key] value:nil] build]];
                        }
                    } break;
                        
                    case GBAnalyticsNetworkFlurry: {
                        [Flurry logEvent:event withParameters:dictionary];
                    } break;
                        
                    case GBAnalyticsNetworkTapstream: {
                        TSEvent *e = [TSEvent eventWithName:event oneTimeOnly:NO];
                        
                        BOOL shouldSend = NO;
                        for (NSString *key in dictionary) {
                            id value = dictionary[key];
                            
                            if ([value isKindOfClass:NSString.class]) {
                                [e addValue:value forKey:key];
                                shouldSend = YES;
                            }
                            else if ([value isKindOfClass:NSNumber.class]) {
                                if (strcmp([value objCType], @encode(BOOL)) == 0) {
                                    [e addBooleanValue:[value boolValue] forKey:key];
                                    shouldSend = YES;
                                }
                                else if ((strcmp([value objCType], @encode(int)) == 0) ||
                                         (strcmp([value objCType], @encode(long)) == 0)) {
                                    [e addIntegerValue:[value intValue] forKey:key];
                                    shouldSend = YES;
                                }
                                else if ((strcmp([value objCType], @encode(unsigned int)) == 0) ||
                                         (strcmp([value objCType], @encode(unsigned long)) == 0)) {
                                    [e addUnsignedIntegerValue:[value unsignedIntValue] forKey:key];
                                    shouldSend = YES;
                                }
                                else if ((strcmp([value objCType], @encode(float)) == 0) ||
                                         (strcmp([value objCType], @encode(double)) == 0)) {
                                    [e addDoubleValue:[value doubleValue] forKey:key];
                                    shouldSend = YES;
                                }
                            }
                        }
                        
                        if (shouldSend) [[TSTapstream instance] fireEvent:e];
                    } break;
                        
                    default:
                        break;
                }
            }
        }
        else {
            [self _debugErrorString:@"GBAnalytics: trackEvent: has not been called with a valid non-empty string"];
        }
    #endif
}

+(void)setDebug:(BOOL)enable {
    [GBAnalytics sharedAnalytics].isDebugLoggingEnabled = enable;
}

+(BOOL)isDebugEnabled {
    return [GBAnalytics sharedAnalytics].isDebugLoggingEnabled;
}

#pragma mark - Debug Logging

+(void)_debugLogSessionStartWithNetwork:(GBAnalyticsNetwork)network {
    if ([GBAnalytics sharedAnalytics].isDebugLoggingEnabled) {
        [self _debugLogEvent:[NSString stringWithFormat:@"GBAnalytics: Started session with analytics network: %@", [self _networkNameForNetwork:network]]];
    }
}

+(void)_debugErrorString:(NSString *)warning {
    if ([GBAnalytics sharedAnalytics].isDebugLoggingEnabled) {
        [self _debugType:@"Error" withString:warning];
    }
}

+(void)_debugWarningString:(NSString *)warning {
    if ([GBAnalytics sharedAnalytics].isDebugLoggingEnabled) {
        [self _debugType:@"Warning" withString:warning];
    }
}

+(void)_debugLogEvent:(NSString *)event {
    if ([GBAnalytics sharedAnalytics].isDebugLoggingEnabled) {
        [self _debugType:@"Log" withString:event];
    }
}

+(void)_debugLogEvent:(NSString *)event withDictionary:(NSDictionary *)dictionary {
    if ([GBAnalytics sharedAnalytics].isDebugLoggingEnabled) {
        [self _debugType:@"Log" withString:event withDictionary:dictionary];
    }
}

+(void)_debugType:(NSString *)type withString:(NSString *)event {
    NSLog(@"GBAnalytics %@: %@", type, event);
}
+(void)_debugType:(NSString *)type withString:(NSString *)event withDictionary:(NSDictionary *)dictionary {
    NSLog(@"GBAnalytics %@: %@, %@", type, event, dictionary);
}

#pragma mark - Util

+(NSString *)_networkNameForNetwork:(GBAnalyticsNetwork)network {
    switch (network) {
        case GBAnalyticsNetworkGoogleAnalytics: {
            return @"Google Analytics";
        } break;
            
        case GBAnalyticsNetworkFlurry: {
            return @"Flurry";
        } break;
            
        case GBAnalyticsNetworkCrashlytics: {
            return @"Crashlytics";
        } break;
            
        case GBAnalyticsNetworkTapstream: {
            return @"Tapstream";
        } break;
            
        case GBAnalyticsNetworkFacebook: {
            return @"Facebook";
        } break;
            
        default: {
            return @"Unkown Network";
        } break;
    }
}

@end
