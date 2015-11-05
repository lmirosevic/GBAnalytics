//
//  GBAnalyticsModule_GoogleAnalytics.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GBAnalyticsModule.h"

@interface GBAnalyticsModule_GoogleAnalytics : NSObject <GBAnalyticsModule>

@property (assign, nonatomic) NSTimeInterval                                dispatchInterval;                       //default: 10
@property (assign, nonatomic) BOOL                                          shouldTrackUncaughtExceptions;          //default: NO

@end

@interface GBAnalyticsSettings (GoogleAnalytics)

@property (strong, nonatomic, readonly) GBAnalyticsModule_GoogleAnalytics   *GoogleAnalytics;

@end
