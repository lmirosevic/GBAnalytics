//
//  GBAnalyticsCore.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GBAnalyticsNetworks.h"

extern NSString * const kGBAnalyticsDefaultEventRoute;

#define GBAnalytics ([GBAnalyticsManager sharedManager])
#define GBAnalyticsEnabled _GBAnalyticsEnabled()
BOOL _GBAnalyticsEnabled();

@class GBAnalyticsEventRouter;
@class GBAnalyticsSettings;

#pragma mark - GBAnalyticsManager

@protocol GBAnalyticsEventRouterInterface <NSObject>

/**
 Set which networks events should be sent to. For the default route, events are sent to all networks. For all custom routes events are sent to no network by default.
 */
- (void)routeToNetworks:(GBAnalyticsNetwork)network, ... NS_REQUIRES_NIL_TERMINATION;

/**
 The set of networks which events should be routed to. All values are boxed inside an NSNumber.
 */
@property (copy, nonatomic) NSSet                                                   *networksToRouteTo;

/**
 Track a simple event.
 */
- (void)trackEvent:(NSString *)event;

/**
 Track an event with a params dictionary. The library will try to normalise this as far as possible for the different analytics networks.
 */
- (void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters;

@end

@interface GBAnalyticsManager : NSObject

/**
 Use this property to configure whether GBAnalytics should output debug information to the console
 */
@property (assign, nonatomic, setter = setDebug:, getter = isDebugEnabled) BOOL     isDebugEnabled;

/**
 Use this property to force the analytics to send data, even when running in DEBUG mode like in the Simulator
 
 Defaults to NO
 
 Make sure to call this before any other calls.
 */
@property (assign, nonatomic) BOOL                                                  force;

/**
 Configuration object for controlling the analytics network behaviour
 */
@property (strong, nonatomic, readonly) GBAnalyticsSettings                         *settings;

/**
 Shared instance singleton
 */
+ (GBAnalyticsManager *)sharedManager;

/**
 Enables a given analytics network. See GBAnalyticsNetworks.h for param list
 */
- (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials, ...;

/**
 This is the square bracket syntax for choosing the event router
 */
- (GBAnalyticsEventRouter *)objectForKeyedSubscript:(NSString *)route;

@end

@interface GBAnalyticsManager (DefaultRouteAliases) <GBAnalyticsEventRouterInterface>
@end

#pragma mark - GBAnalyticsEventRouter

@interface GBAnalyticsEventRouter : NSObject <GBAnalyticsEventRouterInterface>

/**
 Returns the name of the route.
 */
@property (copy, nonatomic, readonly) NSString *route;

@end

#pragma mark - Settings

/**
 This class is empty, and the individual modules add their settings implementations in here with a categiry
 */
@interface GBAnalyticsSettings : NSObject

@end

#pragma mark - Shorthands

/**
 Track a simple event.
 */
static inline void TrackEvent(NSString *event) { [GBAnalytics trackEvent:event]; }

/**
 Track an event with a params dictionary. The library will try to normalise this as far as possible for the different analytics networks.
 */
static inline void TrackEventWithParameters(NSString *event, NSDictionary *parameters) { [GBAnalytics trackEvent:event withParameters:parameters]; }

#pragma mark - Super Shorthands

/**
 Track a simple event.
 */
static inline void _t(NSString *event) { TrackEvent(event); }

/**
 Track an event with a params dictionary. The library will try to normalise this as far as possible for the different analytics networks.
 */
static inline void _tp(NSString *event, NSDictionary *parameters) { TrackEventWithParameters(event, parameters); }
