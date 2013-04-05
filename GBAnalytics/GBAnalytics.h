//
//  GBAnalytics.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GBAnalyticsNetworks.h"

@interface GBAnalytics : NSObject

//See GBAnalyticsNetworks.h for param list
+(void)startSessionWithNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials, ...;

+(void)trackEvent:(NSString *)event;
+(void)trackEvent:(NSString *)event withDictionary:(NSDictionary *)dictionary;//only supported by flurry
#define _t(event) ([GBAnalytics trackEvent:event])
#define _td(event, dictionary) ([GBAnalytics trackEvent:event withDictionary:dictionary])

+(void)setDebug:(BOOL)enable;
+(BOOL)isDebugEnabled;

@end