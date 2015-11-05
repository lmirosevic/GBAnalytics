//
//  GBAnalyticsModule_Amplitude.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GBAnalyticsModule.h"

@interface GBAnalyticsModule_Amplitude : NSObject <GBAnalyticsModule>

@property (assign, nonatomic) BOOL                                      enableLocationListening;                //default: YES
@property (assign, nonatomic) BOOL                                      useAdvertisingIdForDeviceId;            //default: YES

@end

@interface GBAnalyticsSettings (Amplitude)

@property (strong, nonatomic, readonly) GBAnalyticsModule_Amplitude     *Amplitude;

@end
