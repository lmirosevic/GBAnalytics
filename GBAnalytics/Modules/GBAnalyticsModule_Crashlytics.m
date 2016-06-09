//
//  GBAnalyticsModule_Crashlytics.m
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsModule_Crashlytics.h"

#import "GBAnalyticsCore.h"

#import <Crashlytics/Crashlytics.h>
#import <Fabric/Fabric.h>

static NSString * const kGBAnalyticsCredentialsFabricAPIKey = @"kGBAnalyticsCredentialsFabricAPIKey";

@implementation GBAnalyticsModule_Crashlytics

+ (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials args:(va_list)args {
    // this one might be called again from Answers, as that one is just an alias, so we want to be idempotent
    if (![GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkCrashlytics)]) {
        NSString *APIKey = credentials;
        
        if (APIKey.length > 0) {
            [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkCrashlytics)] = @{kGBAnalyticsCredentialsFabricAPIKey: APIKey};

            [Crashlytics startWithAPIKey:APIKey];
        }
        else [GBAnalyticsManager signalInvalidCredentialsForNetwork:network];
    }
}

+ (void)trackEvent:(NSString *)event {
    [Answers logCustomEventWithName:event customAttributes:nil];
}

+ (void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
    [Answers logCustomEventWithName:event customAttributes:parameters];
}

@end
