//
//  GBAnalyticsModule_Answers.m
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsModule_Answers.h"

#import "GBAnalyticsModule_Crashlytics.h"

@implementation GBAnalyticsModule_Answers

+ (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials args:(va_list)args {
    [GBAnalyticsModule_Crashlytics connectNetwork:network withCredentials:credentials args:args];
}

+ (void)trackEvent:(NSString *)event {
    [GBAnalyticsModule_Crashlytics trackEvent:event];
}

+ (void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
    [GBAnalyticsModule_Crashlytics trackEvent:event withParameters:parameters];
}

@end
