//
//  GBAnalyticsModule_Parse.m
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsModule_Parse.h"

#import "GBAnalyticsCore.h"

#import "Parse.h"

static NSString * const kGBAnalyticsCredentialsParseApplicationID =                     @"kGBAnalyticsCredentialsParseApplicationID";
static NSString * const kGBAnalyticsCredentialsParseClientKey =                         @"kGBAnalyticsCredentialsParseClientKey";

@implementation GBAnalyticsModule_Parse

+ (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials args:(va_list)args {
    NSString *ApplicationID = credentials;
    NSString *ClientKey = va_arg(args, NSString *);
    
    if (ApplicationID.length > 0 && ClientKey.length > 0) {
        [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkParse)] = @{kGBAnalyticsCredentialsParseApplicationID: ApplicationID, kGBAnalyticsCredentialsParseClientKey: ClientKey};
        
        [Parse setApplicationId:ApplicationID clientKey:ClientKey];
        
        [[GBAnalyticsManager sharedManager] addHandlerForApplicationNotification:^(NSString *notificationName, NSDictionary *userInfo) {
            if ([notificationName isEqualToString:UIApplicationDidFinishLaunchingNotification]) {
                [PFAnalytics trackAppOpenedWithLaunchOptions:userInfo];
            }
        }];
    }
    else [GBAnalyticsManager signalInvalidCredentialsForNetwork:network];
}

+ (void)trackEvent:(NSString *)event {
    // we need to remove spaces from the event name
    NSString *safeEventName = [event stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    // send the actual event
    [PFAnalytics trackEvent:safeEventName];
}

+ (void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
    // we need to remove spaces from the event name
    NSString *safeEventName = [event stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    // we need to flatten the dictionary because otherwise it causes an error
    NSMutableDictionary *flatDictionary = [NSMutableDictionary new];
    for (NSString *key in parameters) {
        id value = parameters[key];
        
        // KEY
        NSString *keyString;
        
        // force as string
        keyString = [key description];
        
        // VALUE
        NSString *valueString;
        
        // try json first
        if ([NSJSONSerialization isValidJSONObject:value]) {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value
                                                               options:0
                                                                 error:&error];
            
            // we got some data and no error was returned
            if (jsonData && !error) {
                // we update the string
                valueString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        }
        
        // JSON didn't work
        if (!valueString) {
            
            valueString = [value description];
        }
        
        // put it into the flat dictionary
        flatDictionary[keyString] = valueString;
    }
    
    // send the actual data
    [PFAnalytics trackEvent:safeEventName dimensions:flatDictionary];
}

@end
