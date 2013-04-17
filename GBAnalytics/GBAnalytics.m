//
//  GBAnalytics.m
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import "GBAnalytics.h"

static NSString * const kGBAnalyticsCredentialsGoogleAnalyticsTrackingID = @"kGBAnalyticsCredentialsGoogleAnalyticsTrackingID";
static NSString * const kGBAnalyticsCredentialsFlurryAPIKey = @"kGBAnalyticsCredentialsFlurryAPIKey";
static NSString * const kGBAnalyticsCredentialsBugSenseAPIKey = @"kGBAnalyticsCredentialsBugSenseAPIKey";
static NSString * const kGBAnalyticsCredentialsCrashlyticsAPIKey = @"kGBAnalyticsCredentialsCrashlyticsAPIKey";

@interface GBAnalytics ()

@property (strong, nonatomic) NSMutableDictionary       *connectedAnalyticsNetworks;
@property (assign, nonatomic) BOOL                      isDebugLoggingEnabled;

@end


@implementation GBAnalytics

#pragma mark - Storage

_singleton(GBAnalytics, sharedAnalytics)
#define _GBAnalytics [GBAnalytics sharedAnalytics]
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
    if ([self isDebugEnabled]) {
        [self _debugLogSessionStartWithNetwork:network];
    }
    
    va_list args;
    va_start(args, credentials);
    
    switch (network) {
        case GBAnalyticsNetworkGoogleAnalytics: {
            if (IsValidString(credentials)) {
                [GBAnalytics sharedAnalytics].connectedAnalyticsNetworks[@(GBAnalyticsNetworkGoogleAnalytics)] = @{kGBAnalyticsCredentialsGoogleAnalyticsTrackingID: credentials};
                
                [GAI sharedInstance].trackUncaughtExceptions = NO;
                [[GAI sharedInstance] trackerWithTrackingId:credentials];
            }
            else {
                NSAssert(NO, @"GBAnalytics Error: Didn't pass valid credentials for Google Analytics");
            }
        } break;
            
        case GBAnalyticsNetworkFlurry: {
            if (IsValidString(credentials)) {
                [GBAnalytics sharedAnalytics].connectedAnalyticsNetworks[@(GBAnalyticsNetworkFlurry)] = @{kGBAnalyticsCredentialsFlurryAPIKey: credentials};
                
                [Flurry startSession:credentials];
            }
            else {
                NSAssert(NO, @"GBAnalytics Error: Didn't pass valid credentials for Flurry");
            }
        } break;
            
        case GBAnalyticsNetworkBugSense: {
            if (IsValidString(credentials)) {
                [GBAnalytics sharedAnalytics].connectedAnalyticsNetworks[@(GBAnalyticsNetworkBugSense)] = @{kGBAnalyticsCredentialsBugSenseAPIKey: credentials};
                
                [BugSenseController sharedControllerWithBugSenseAPIKey:credentials];
            }
            else {
                NSAssert(NO, @"GBAnalytics Error: Didn't pass valid credentials for BugSense");
            }
        } break;
            
        case GBAnalyticsNetworkCrashlytics: {
            if (IsValidString(credentials)) {
                [GBAnalytics sharedAnalytics].connectedAnalyticsNetworks[@(GBAnalyticsNetworkCrashlytics)] = @{kGBAnalyticsCredentialsCrashlyticsAPIKey: credentials};
                
                [Crashlytics startWithAPIKey:credentials];
            }
            else {
                NSAssert(NO, @"GBAnalytics Error: Didn't pass valid credentials for Crashlytics");
            }
        } break;
            
        default:
            return;
    }
    
    va_end(args);
}

+(void)trackEvent:(NSString *)event {
    if ([self isDebugEnabled]) {
        [self _debugLogEvent:event];
    }
    
    for (NSNumber *number in [GBAnalytics sharedAnalytics].connectedAnalyticsNetworks) {
        GBAnalyticsNetwork network = [number intValue];
        
        switch (network) {
            case GBAnalyticsNetworkGoogleAnalytics: {
                if (IsValidString(event)) {
                    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"GBAnalytics" withAction:event withLabel:nil withValue:nil];
                }
                else {
                    [self _debugErrorString:@"TrackEvent has not been called with a valid non-empty string"];
                }
            } break;
                
            case GBAnalyticsNetworkFlurry: {
                if (IsValidString(event)) {
                    [Flurry logEvent:event];
                }
                else {
                    [self _debugErrorString:@"TrackEvent has not been called with a valid non-empty string"];
                }
                
            } break;
                
            default:
                break;
        }
    }
}

+(void)trackEvent:(NSString *)event withDictionary:(NSDictionary *)dictionary {
    if ([self isDebugEnabled]) {
        [self _debugLogEvent:event withDictionary:dictionary];
    }
    
    for (NSNumber *number in [GBAnalytics sharedAnalytics].connectedAnalyticsNetworks) {
        GBAnalyticsNetwork network = [number intValue];
        
        switch (network) {
            case GBAnalyticsNetworkGoogleAnalytics: {
                [self _debugWarningString:_f(@"Event not sent to Google Analytics (%@)", event)];
            } break;
                
            case GBAnalyticsNetworkFlurry: {
                if (IsValidString(event) && dictionary) {
                    [Flurry logEvent:event withParameters:dictionary];
                }
                else {
                    [self _debugErrorString:@"TrackEvent has not been called with a valid non-empty string and valid dictionary"];
                }
            } break;
                
            default:
                break;
        }
    }
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
        NSString *networkName;
        
        switch (network) {
            case GBAnalyticsNetworkGoogleAnalytics:
                networkName = @"Google Analytics";
                break;
                
            case GBAnalyticsNetworkFlurry:
                networkName = @"Flurry";
                break;
                
            case GBAnalyticsNetworkBugSense:
                networkName = @"BugSense";
                break;
                
            case GBAnalyticsNetworkCrashlytics:
                networkName = @"Crashlytics";
                break;
                
            default:
                networkName = @"Unkown Network";
                break;
        }
        
        [self _debugType:@"Log" withString:_f(@"Started session with analytics network: %@", networkName)];
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
    l(@"GBAnalytics %@: %@", type, event);
}
+(void)_debugType:(NSString *)type withString:(NSString *)event withDictionary:(NSDictionary *)dictionary {
    l(@"GBAnalytics %@: %@, %@", type, event, dictionary);
}

@end
