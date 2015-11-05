//
//  GBAnalyticsModule_Tapstream.m
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsModule_Tapstream.h"

#import "GBAnalyticsCore.h"

#import <Tapstream/TSTapstream.h>

static NSString * const kGBAnalyticsCredentialsTapstreamAccountName =                   @"kGBAnalyticsCredentialsTapstreamAccountName";
static NSString * const kGBAnalyticsCredentialsTapstreamSDKSecret =                     @"kGBAnalyticsCredentialsTapstreamSDKSecret";

static TapstreamLogger const kDefaultTapstreamLogger =                                  nil;

@implementation GBAnalyticsModule_Tapstream

- (id)init {
    if (self = [super init]) {
        self.logger = kDefaultTapstreamLogger;
    }
    
    return self;
}

+ (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials args:(va_list)args {
    NSString *AccountName = credentials;
    NSString *SDKSecret = va_arg(args, NSString *);
    
    if (IsValidString(AccountName) && IsValidString(SDKSecret)) {
        [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkTapstream)] = @{kGBAnalyticsCredentialsTapstreamAccountName: AccountName, kGBAnalyticsCredentialsTapstreamSDKSecret: SDKSecret};
        
        [TSLogging setLogger:[GBAnalyticsManager sharedManager].settings.Tapstream.logger];
        TSConfig *config = [TSConfig configWithDefaults];
        [TSTapstream createWithAccountName:AccountName developerSecret:SDKSecret config:config];
    }
    else [GBAnalyticsManager signalInvalidCredentialsForNetwork:network];
}

+ (void)trackEvent:(NSString *)event {
    [[TSTapstream instance] fireEvent:[TSEvent eventWithName:event oneTimeOnly:NO]];
}

+ (void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
    TSEvent *e = [TSEvent eventWithName:event oneTimeOnly:NO];
    for (NSString *key in parameters) {
        [e addValue:parameters[key] forKey:key];
    }
    
    [[TSTapstream instance] fireEvent:e];
}

@end
