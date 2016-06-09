//
//  GBAnalyticsModule_Facebook.m
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsModule_Facebook.h"

#import "GBAnalyticsCore.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>

static NSString * const kGBAnalyticsCredentialsFacebookAppID =                          @"kGBAnalyticsCredentialsFacebookAppID";

@implementation GBAnalyticsModule_Facebook

+ (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials args:(va_list)args {
    NSString *FBAppID = credentials ?: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
    
    if (FBAppID.length > 0) {
        [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkFacebook)] = @{kGBAnalyticsCredentialsFacebookAppID: FBAppID};
        [FBSDKSettings setAppID:FBAppID];
    }
    else [GBAnalyticsManager signalInvalidCredentialsForNetwork:network];
}

+ (void)trackEvent:(NSString *)event {
   [FBSDKAppEvents logEvent:[self _formatEventNameForFacebook:event]];
}

+ (void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
   [FBSDKAppEvents logEvent:[self _formatEventNameForFacebook:event] parameters:parameters];
}

#pragma mark - Private

+ (NSString *)_formatEventNameForFacebook:(NSString *)eventName {
    NSMutableString *formattedName = [eventName mutableCopy];
    
    [formattedName replaceOccurrencesOfString:@"(" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formattedName.length)];
    [formattedName replaceOccurrencesOfString:@")" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formattedName.length)];
    [formattedName replaceOccurrencesOfString:@":" withString:@"-" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formattedName.length)];
    if (formattedName.length > 40) [formattedName deleteCharactersInRange:NSMakeRange(40, formattedName.length - 40)];
    
    return [formattedName copy];
}

@end
