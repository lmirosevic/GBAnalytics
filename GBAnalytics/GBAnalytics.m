//
//  GBAnalytics.m
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import "GBAnalytics.h"

static NSString *kGBAnalyticsCredentialsGoogleAnalyticsTrackingID = @"kGBAnalyticsCredentialsGoogleAnalyticsTrackingID";

static NSString *kGBAnalyticsCredentialsFlurryAPIKey = @"kGBAnalyticsCredentialsFlurryAPIKey";

@interface GBAnalytics ()

@property (strong, nonatomic) NSMutableDictionary       *connectedAnalyticsNetworks;
@property (assign, nonatomic) BOOL                      enableDebugLogging;

@end


@implementation GBAnalytics

#pragma mark - Storage

_singleton(GBAnalytics, sharedAnalytics)
_lazy(NSMutableDictionary, connectedAnalyticsNetworks, _connectedAnalyticsNetworks)

#pragma mark - Initialiser

-(id)init {
    if (self = [super init]) {
#if APPSTORE
        self.enableDebugLogging = NO;
#else
        self.enableDebugLogging = YES;
#endif
    }
    
    return self;
}

#if APPSTORE
#pragma mark - Public API (AppStore)

+(void)startSessionWithNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials, ... {
    [self _debugLogSessionStartWithNetwork:network];
    
    va_list args;
    va_start(args, credentials);
    
    switch (network) {
        case GBAnalyticsNetworkGoogleAnalytics: {
            if (IsValidString(credentials)) {
                [GBAnalytics sharedAnalytics].connectedAnalyticsNetworks[@(GBAnalyticsNetworkGoogleAnalytics)] = @{kGBAnalyticsCredentialsGoogleAnalyticsTrackingID: credentials};
                
                [GAI sharedInstance].trackUncaughtExceptions = YES;//foo not sure abt this
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
                NSAssert(NO, @"GBAnalytics Error: Didn't pass valid credentials for Google Analytics");
            }
        } break;
            
        default:
            return;
    }
    
    va_end(args);
}

+(void)trackEvent:(NSString *)event {
    [self _debugLogEvent:event];
    
    for (NSNumber *number in [GBAnalytics sharedAnalytics].connectedAnalyticsNetworks) {
        GBAnalyticsNetwork network = [number intValue];
        
        switch (network) {
            case GBAnalyticsNetworkGoogleAnalytics: {
                if (IsValidString(event)) {
                    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"GBAnalytics" withAction:event withLabel:nil withValue:nil];
                }
                else {
                    l(@"GBAnalytics Error: trackEvent has not been called with a valid non-empty string");
                }
            } break;
                
            case GBAnalyticsNetworkFlurry: {
                if (IsValidString(event)) {
                    [Flurry logEvent:event];
                }
                else {
                    l(@"GBAnalytics Error: trackEvent has not been called with a valid non-empty string");
                }
                
            } break;
                
            default:
                break;
        }
    }
}

+(void)trackEvent:(NSString *)event withDictionary:(NSDictionary *)dictionary {
    [self _debugLogEvent:event withDictionary:dictionary];
    
    for (NSNumber *number in [GBAnalytics sharedAnalytics].connectedAnalyticsNetworks) {
        GBAnalyticsNetwork network = [number intValue];
        
        switch (network) {
            case GBAnalyticsNetworkGoogleAnalytics: {
                l(@"GBAnalytics Warning: event not sent to Google Analytics (%@)", event);
            } break;
                
            case GBAnalyticsNetworkFlurry: {
                if (IsValidString(event) && dictionary) {
                    [Flurry logEvent:event withParameters:dictionary];
                }
                else {
                    l(@"GBAnalytics Error: trackEvent has not been called with a valid non-empty string and valid dictionary");
                }
                
            } break;
                
            default:
                break;
        }
    }
}

#else
#pragma mark - Public API (Debugging)

+(void)startSessionWithNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials, ... {
    [self _debugLogSessionStartWithNetwork:network];
}

+(void)trackEvent:(NSString *)event {
    [self _debugLogEvent:event];
}

+(void)trackEvent:(NSString *)event withDictionary:(NSDictionary *)dictionary {
    [self _debugLogEvent:event withDictionary:dictionary];
}

#endif

#pragma mark - Debug Logging

+(void)enableDebugLogging:(BOOL)enable {
    [GBAnalytics sharedAnalytics].enableDebugLogging = enable;
}

+(void)_debugLogSessionStartWithNetwork:(GBAnalyticsNetwork)network {
    if ([GBAnalytics sharedAnalytics].enableDebugLogging) {
        NSString *networkName;
        
        switch (network) {
            case GBAnalyticsNetworkGoogleAnalytics:
                networkName = @"Google Analytics";
                break;
                
            case GBAnalyticsNetworkFlurry:
                networkName = @"Flurry";
                break;
                
            default:
                networkName = @"Unkown Network";
                break;
        }
        
        l(@"GBAnalytics Log: connected to network: %@", networkName);
    }
}

+(void)_debugLogEvent:(NSString *)event {
    if ([GBAnalytics sharedAnalytics].enableDebugLogging) {
        l(@"GBAnalytics Log: %@", event);
    }
}

+(void)_debugLogEvent:(NSString *)event withDictionary:(NSDictionary *)dictionary {
    if ([GBAnalytics sharedAnalytics].enableDebugLogging) {
        l(@"GBAnalytics Log: %@, %@", event, dictionary);
    }
}

@end
