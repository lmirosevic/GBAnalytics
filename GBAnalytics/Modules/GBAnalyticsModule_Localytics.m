//
//  GBAnalyticsModule_Localytics.m
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsModule_Localytics.h"

#import "GBAnalyticsCore.h"

#import "Localytics.h"

static NSString * const kGBAnalyticsCredentialsLocalyticsAppKey =                       @"kGBAnalyticsCredentialsLocalyticsAppKey";

static BOOL const kDefaultLocalyticsIsCollectingAvertisingIdentifier =                  YES;
static NSTimeInterval const kDefaultLocalyticsTimeoutInterval =                         15;


@implementation GBAnalyticsModule_Localytics
- (id)init {
    if (self = [super init]) {
        self.isCollectingAdvertisingIdentifier = kDefaultLocalyticsIsCollectingAvertisingIdentifier;
        self.sessionTimeoutInterval = kDefaultLocalyticsTimeoutInterval;
    }
    
    return self;
}

+ (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials args:(va_list)args {
    NSString *AppKey = credentials;
    
    if (AppKey.length > 0) {
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
