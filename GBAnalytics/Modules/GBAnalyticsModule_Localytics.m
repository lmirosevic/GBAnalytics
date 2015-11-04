//
//  GBAnalytics.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsModule_GoogleAnalytics.h"

#import "GBAnalytics.h"

#import <Localytics/Localytics.h>

static NSString * const kGBAnalyticsCredentialsLocalyticsAppKey =                       @"kGBAnalyticsCredentialsLocalyticsAppKey";

@implementation GBAnalyticsModule_GoogleAnalaytics

+ (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials args:(va_list)args {
    NSString *AppKey = credentials;
    
    if (IsValidString(AppKey)) {
        [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkLocalytics)] = @{kGBAnalyticsCredentialsLocalyticsAppKey: AppKey};
        
        [Localytics integrate:AppKey];
        
        [Localytics setCollectAdvertisingIdentifier:[GBAnalyticsManager sharedManager].settings.Localytics.isCollectingAdvertisingIdentifier];
        [Localytics setSessionTimeoutInterval:[GBAnalyticsManager sharedManager].settings.Localytics.sessionTimeoutInterval];
        
        [[GBAnalyticsManager sharedManager] addHandlerForApplicationNotification:^(NSString *notificationName, NSDictionary *userInfo) {
            if ([notificationName isEqualToString:UIApplicationDidBecomeActiveNotification] ||
                [notificationName isEqualToString:UIApplicationWillEnterForegroundNotification]) {
                [Localytics openSession];
                [Localytics upload];
            }
            else if ([notificationName isEqualToString:UIApplicationWillResignActiveNotification] ||
                     [notificationName isEqualToString:UIApplicationDidEnterBackgroundNotification] ||
                     [notificationName isEqualToString:UIApplicationWillTerminateNotification]) {
                [Localytics closeSession];
                [Localytics upload];
            }
        }];
    }
    else [GBAnalyticsManager signalInvalidCredentialsForNetwork:network];
}

+ (void)trackEvent:(NSString *)event {
   [Localytics tagEvent:event];
}

+ (void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
   [Localytics tagEvent:event attributes:parameters];
}

@end
