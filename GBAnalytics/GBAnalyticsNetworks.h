//
//  GBAnalyticsNetworks.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

#import <FlurrySDK/Flurry.h>

#import <Crashlytics/Crashlytics.h>

#import <Tapstream/TSTapstream.h>

#import <FacebookSDK/FacebookSDK.h>

#import <Mixpanel/Mixpanel.h>

typedef enum {
    GBAnalyticsNetworkGoogleAnalytics = 1,
    GBAnalyticsNetworkFlurry,
    GBAnalyticsNetworkCrashlytics,
    GBAnalyticsNetworkTapstream,
    GBAnalyticsNetworkFacebook,
    GBAnalyticsNetworkMixpanel,
} GBAnalyticsNetwork;

#define kGBAnalyticsFacebookAppIDFromPlist nil

#define kGBAnalyticsTapstreamConversionEventNotification @"kGBAnalyticsTapstreamConversionEventNotification"

/* Networks
 
 Flurry
   Params: FlurryAPIKey
   Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkFlurry withCredentials:@"FlurryAPIKey"];
 
 
 Google Analytics
   Params: GoogleAnalyticsTrackingID
   Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkGoogleAnalytics withCredentials:@"GoogleAnalyticsTrackingID"];
 
 
 Crashlytics
   Params: CrashlyticsAPIKey
   Example: [GBAnalytics startSessionWithNetwork:GBAnalyticsNetworkCrashlytics withCredentials:@"CrashlyticsAPIKey"];
 
 Tapsteam
    Params: TapstreamAccountName, TapstreamSDKSecret
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkTapstream withCredentials:@"TapstreamAccountName", @"TapstreamSDKSecret"];
 
 Facebook
    Params: FacebookAppID (or leave nil to get it from the FacebookAppID key in the Info.plist)
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkFacebook withCredentials:@"FacebookAppID"];
 
 Mixpanel
    Params: MixpanelToken
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkMixpanel withCredentials:@"MixpanelToken"];
  
 */