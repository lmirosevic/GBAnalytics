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
+(void)trackEvent:(NSString *)event withDictionary:(NSDictionary *)dictionary;

+(void)setDebug:(BOOL)enable;
+(BOOL)isDebugEnabled;

@end

//Shorthands
static inline void TrackEvent(NSString *event) { [GBAnalytics trackEvent:event]; }
static inline void TrackEventWithDictionary(NSString *event, NSDictionary *dictionary) { [GBAnalytics trackEvent:event withDictionary:dictionary]; }

//Super Shorthands
static inline void _t(NSString *event) { TrackEvent(event); }
static inline void _td(NSString *event, NSDictionary *dictionary) { TrackEventWithDictionary(event, dictionary); }
