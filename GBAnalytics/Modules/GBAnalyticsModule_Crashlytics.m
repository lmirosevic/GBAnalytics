//
//  GBAnalytics.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsModule_GoogleAnalytics.h"

#import "GBAnalytics.h"

#import <Crashlytics/Crashlytics.h>
#import <Fabric/Fabric.h>

static NSString * const kGBAnalyticsCredentialsCrashlyticsAPIKey =                      @"kGBAnalyticsCredentialsCrashlyticsAPIKey";

@implementation GBAnalyticsModule_GoogleAnalaytics

+ (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials args:(va_list)args {
    NSString *APIKey = credentials;

    if (IsValidString(APIKey)) {
        [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkCrashlytics)] = @{kGBAnalyticsCredentialsCrashlyticsAPIKey: APIKey};

        [Crashlytics startWithAPIKey:APIKey];
    }
    else [GBAnalyticsManager signalInvalidCredentialsForNetwork:network];
}

+ (void)trackEvent:(NSString *)event {
    // noop, doesn't support events
}

+ (void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
    // noop, doesn't support events
}

@end
