//
//  GBAnalyticsModule_Localytics.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GBAnalyticsModule.h"

@interface GBAnalyticsModule_Localytics : NSObject <GBAnalyticsModule>

@property (assign, nonatomic) BOOL                                      isCollectingAdvertisingIdentifier;      //default: YES
@property (assign, nonatomic) NSTimeInterval                            sessionTimeoutInterval;                 //default: 15

@end

@interface GBAnalyticsSettings (Localytics)

@property (strong, nonatomic, readonly) GBAnalyticsModule_Localytics    *Localytics;

@end
