//
//  GBAnalyticsModule.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GBAnalyticsCore.h"

typedef void(^ApplicationDidGenerateNotificationBlock)(NSString *notificationName, NSDictionary *userInfo);

@protocol GBAnalyticsModule <NSObject>
@required

+ (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials args:(va_list)args;
+ (void)trackEvent:(NSString *)event;
+ (void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters;

@end

@interface GBAnalyticsManager (ModuleSupport)

/**
 Property to allow the individual module implemntations, as a user you should not mess with the keys in here.
 */
@property (strong, nonatomic, readonly) NSMutableDictionary                         *connectedAnalyticsNetworks;

/**
 Used to signal that the credentials passed were invalid.
 */
+ (void)signalInvalidCredentialsForNetwork:(GBAnalyticsNetwork)network;

/**
 Used by some modules which need to hook into the application notifications stream.
 */
- (void)addHandlerForApplicationNotification:(ApplicationDidGenerateNotificationBlock)block;

@end
