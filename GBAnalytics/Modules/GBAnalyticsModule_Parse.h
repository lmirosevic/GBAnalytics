//
//  GBAnalyticsModule_Parse.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GBAnalyticsModule.h"

@interface GBAnalyticsModule_Parse : NSObject <GBAnalyticsModule>

@end

@interface GBAnalyticsSettings (Parse)

@property (strong, nonatomic, readonly) GBAnalyticsModule_Parse     *Parse;

@end
