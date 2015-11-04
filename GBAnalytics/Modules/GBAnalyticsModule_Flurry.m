//
//  GBAnalytics.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsModule_GoogleAnalytics.h"

#import "GBAnalytics.h"

#import <Flurry-iOS-SDK/Flurry.h>

static NSString * const kGBAnalyticsCredentialsFlurryAPIKey =                           @"kGBAnalyticsCredentialsFlurryAPIKey";

@implementation GBAnalyticsModule_GoogleAnalaytics

+ (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials args:(va_list)args {
    NSString *APIKey = credentials;
    
    if (IsValidString(APIKey)) {
        [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkFlurry)] = @{kGBAnalyticsCredentialsFlurryAPIKey: APIKey};
        
        [Flurry startSession:APIKey];
    }    else [GBAnalyticsManager signalInvalidCredentialsForNetwork:network];
}

+ (void)trackEvent:(NSString *)event {
    [Flurry logEvent:event];
}

+ (void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
    [Flurry logEvent:event withParameters:parameters];
}

@end
