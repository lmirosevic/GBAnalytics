//
//  GBAnalyticsNetworks.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import "Flurry.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"

#import <Crashlytics/Crashlytics.h>

#import "TSTapstream.h"

#import <FacebookSDK/FacebookSDK.h>

typedef enum {
    GBAnalyticsNetworkGoogleAnalytics = 1,
    GBAnalyticsNetworkFlurry,
    GBAnalyticsNetworkCrashlytics,
    GBAnalyticsNetworkTapstream,
    GBAnalyticsNetworkFacebook,
} GBAnalyticsNetwork;

#define kGBAnalyticsFacebookAppIDFromPlist nil

/* Networks
 
 Flurry
   Params: FlurryAPIKey
   Example: [GBAnalytics startSessionWithNetwork:GBAnalyticsNetworkFlurry withCredentials:@"FlurryAPIKey"];
 
 
 Google Analytics
   Params: GoogleAnalyticsTrackingID
   Example: [GBAnalytics startSessionWithNetwork:GBAnalyticsNetworkGoogleAnalytics withCredentials:@"GoogleAnalyticsTrackingID"];
 
 
 Crashlytics
   Params: CrashlyticsAPIKey
   Example: [GBAnalytics startSessionWithNetwork:GBAnalyticsNetworkCrashlytics withCredentials:@"CrashlyticsAPIKey"];
 
 Tapsteam
    Params: TapstreamAccountName, TapstreamSDKSecret
    Example: [GBAnalytics startSessionWithNetwork:GBAnalyticsNetworkTapstream withCredentials:@"TapstreamAccountName", @"TapstreamSDKSecret"];
 
 Facebook
    Params: FacebookAppID (or leave nil to get it from the FacebookAppID key in the Info.plist)
    Example: [GBAnalytics startSessionWithNetwork:GBAnalyticsNetworkFacebook withCredentials:@"FacebookAppID"];
  
 */
