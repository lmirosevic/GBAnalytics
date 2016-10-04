//
//  GBAnalyticsModule_Amplitude.m
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsModule_Amplitude.h"

#import "GBAnalyticsCore.h"

#import "Amplitude.h"

static NSString * const kGBAnalyticsCredentialsAmplitudeAPIKey =                        @"kGBAnalyticsCredentialsAmplitudeAPIKey";

static BOOL const kDefaultAmplitudeEnableLocationListening =                            YES;
static BOOL const kDefaultAmplitudeUserAdvertisingIdForDeviceId =                       YES;

@implementation GBAnalyticsModule_Amplitude

- (id)init {
    if (self = [super init]) {
        self.enableLocationListening = kDefaultAmplitudeEnableLocationListening;
        self.useAdvertisingIdForDeviceId = kDefaultAmplitudeUserAdvertisingIdForDeviceId;
    }
    
    return self;
}

+ (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials args:(va_list)args {
    NSString *APIKey = credentials;
    
    if (APIKey.length > 0) {
        [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkAmplitude)] = @{kGBAnalyticsCredentialsAmplitudeAPIKey: APIKey};
        
        // for Amplitude, it's important to apply the settings first, before initialising it
        if ([GBAnalyticsManager sharedManager].settings.Amplitude.useAdvertisingIdForDeviceId) {
            [[Amplitude instance] useAdvertisingIdForDeviceId];
        }
        
        if ([GBAnalyticsManager sharedManager].settings.Amplitude.enableLocationListening) {
            [[Amplitude instance] enableLocationListening];
        }
        else {
            [[Amplitude instance] disableLocationListening];
        }
        
        [[Amplitude instance] initializeApiKey:APIKey];
    }
    else [GBAnalyticsManager signalInvalidCredentialsForNetwork:network];
}

+ (void)trackEvent:(NSString *)event {
   [[Amplitude instance] logEvent:event];
}

+ (void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
   [[Amplitude instance] logEvent:event withEventProperties:parameters];
}

@end
