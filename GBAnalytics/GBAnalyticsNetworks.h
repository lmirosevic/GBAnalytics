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
#import <Crashlytics/Crashlytics.h>

typedef enum {
    GBAnalyticsNetworkGoogleAnalytics = 1,
    GBAnalyticsNetworkFlurry,
    GBAnalyticsNetworkBugSense,
    GBAnalyticsNetworkCrashlytics
} GBAnalyticsNetwork;


/* Networks
 
 Flurry
   Params: FlurryAPIKey
   Example: [GBAnalytics startSessionWithNetwork:GBAnalyticsNetworkFlurry withCredentials:@"FlurryAPIKey"];
 
 
 Google Analytics
   Params: GoogleAnalyticsTrackingID
   Example: [GBAnalytics startSessionWithNetwork:GBAnalyticsNetworkGoogleAnalytics withCredentials:@"GoogleAnalyticsTrackingID"];
 
 Bugsense
   Params: BugsenseAPIKey
   Example: [GBAnalytics startSessionWithNetwork:GBAnalyticsNetworkBugSense withCredentials:@"BugsenseAPIKey"];
 
 Crashlytics
   Params: CrashlyticsAPIKey
   Example: [GBAnalytics startSessionWithNetwork:GBAnalyticsNetworkCrashlytics withCredentials:@"CrashlyticsAPIKey"];
 
 */