//
//  GBAnalyticsNetworks.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import "GAI.h"
#import "Flurry.h"
#import <BugSense-iOS/BugSenseController.h>

typedef enum {
    GBAnalyticsNetworkGoogleAnalytics = 1,
    GBAnalyticsNetworkFlurry,
    GBAnalyticsNetworkBugSense,
} GBAnalyticsNetwork;


// Network support:
//
// Google Analytics
// Flurry
// Bugsense