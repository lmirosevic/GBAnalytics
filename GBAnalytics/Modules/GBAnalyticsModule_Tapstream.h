//
//  GBAnalyticsModule_Tapstream.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GBAnalyticsModule.h"

typedef void(^TapstreamLogger)(int, NSString *);

@interface GBAnalyticsModule_Tapstream : NSObject <GBAnalyticsModule>

@property (copy, nonatomic) TapstreamLogger                             logger;                                 //default: nil

@end

@interface GBAnalyticsSettings (Tapstream)

@property (strong, nonatomic, readonly) GBAnalyticsModule_Tapstream     *Tapstream;

@end
