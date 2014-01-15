//
//  GBAnalytics.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GBAnalyticsNetworks.h"
#import "GBAnalyticsSettings.h"

extern NSString * const kGBAnalyticsDefaultEventRoute;

#define GBAnalytics ([GBAnalyticsManager sharedManager])
#define GBAnalyticsEnabled _GBAnalyticsEnabled()
BOOL _GBAnalyticsEnabled();

@class GBAnalyticsEventRouter;

@interface GBAnalyticsManager : NSObject

@property (assign, nonatomic, setter = setDebug:, getter = isDebugEnabled) BOOL     isDebugEnabled;
@property (assign, nonatomic) BOOL                                                  force;//defaults to NO, used to enable analytics when in debug mode. Make sure to call this before any other calls.

@property (strong, nonatomic, readonly) GBAnalyticsSettings                         *settings;

+(GBAnalyticsManager *)sharedManager;

//See GBAnalyticsNetworks.h for param list
-(void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials, ...;

//Allows using the square bracket syntax for choosing the event router
-(GBAnalyticsEventRouter *)objectForKeyedSubscript:(NSString *)route;

@end

@interface GBAnalyticsManager (DefaultAliases)

//These alias the default event router
-(void)routeToNetworks:(GBAnalyticsNetwork)network, ... NS_REQUIRES_NIL_TERMINATION;
-(void)trackEvent:(NSString *)event;
-(void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters;

@end

@interface GBAnalyticsEventRouter : NSObject

@property (copy, nonatomic, readonly) NSString *route;

-(void)routeToNetworks:(GBAnalyticsNetwork)network, ... NS_REQUIRES_NIL_TERMINATION;
-(void)trackEvent:(NSString *)event;
-(void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters;

@end

//Shorthands
static inline void TrackEvent(NSString *event) { [GBAnalytics trackEvent:event]; }
static inline void TrackEventWithParameters(NSString *event, NSDictionary *parameters) { [GBAnalytics trackEvent:event withParameters:parameters]; }

//Super Shorthands
static inline void _t(NSString *event) { TrackEvent(event); }
static inline void _tp(NSString *event, NSDictionary *parameters) { TrackEventWithParameters(event, parameters); }
