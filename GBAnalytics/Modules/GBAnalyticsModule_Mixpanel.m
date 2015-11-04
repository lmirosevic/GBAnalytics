//
//  GBAnalytics.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsModule_GoogleAnalytics.h"

#import "GBAnalytics.h"

#import <Mixpanel/Mixpanel.h>

static NSString * const kGBAnalyticsCredentialsMixpanelToken =                          @"kGBAnalyticsCredentialsMixpanelToken";

@implementation GBAnalyticsModule_GoogleAnalaytics

+ (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials args:(va_list)args {
    NSString *Token = credentials;
    
    if (IsValidString(Token)) {
        [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkMixpanel)] = @{kGBAnalyticsCredentialsMixpanelToken: Token};
        
        [Mixpanel sharedInstanceWithToken:Token];
        [Mixpanel sharedInstance].flushInterval = [GBAnalyticsManager sharedManager].settings.Mixpanel.flushInterval;
        [Mixpanel sharedInstance].showNetworkActivityIndicator = [GBAnalyticsManager sharedManager].settings.Mixpanel.shouldShowNetworkActivityIndicator;
    }
    else [GBAnalyticsManager signalInvalidCredentialsForNetwork:network];
}

+ (void)trackEvent:(NSString *)event {
   [[Mixpanel sharedInstance] track:event];
}

+ (void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
   [[Mixpanel sharedInstance] track:event properties:parameters];
}

@end
