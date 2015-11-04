//
//  GBAnalytics.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsModule_GoogleAnalytics.h"

#import "GBAnalytics.h"

#import <Amplitude-iOS/Amplitude.h>

static NSString * const kGBAnalyticsCredentialsAmplitudeAPIKey =                        @"kGBAnalyticsCredentialsAmplitudeAPIKey";

@implementation GBAnalyticsModule_GoogleAnalaytics

+ (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials args:(va_list)args {
    NSString *APIKey = credentials;
    
    if (IsValidString(APIKey)) {
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
