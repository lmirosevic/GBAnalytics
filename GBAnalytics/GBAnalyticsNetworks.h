//
//  GBAnalyticsNetworks.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//


/* Networks
 
 Flurry
    Params: FlurryAPIKey
    Settings: 
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkFlurry withCredentials:@"FlurryAPIKey"];
 
 Google Analytics
    Params: GoogleAnalyticsTrackingID
    Settings: NSTimeInterval dispatchInterval, BOOL shouldTrackUncaughtExceptions
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkGoogleAnalytics withCredentials:@"GoogleAnalyticsTrackingID"];
 
 Crashlytics
    Params: CrashlyticsAPIKey
    Settings:
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkCrashlytics withCredentials:@"CrashlyticsAPIKey"];
 
 Tapstream
    Params: TapstreamAccountName, TapstreamSDKSecret
    Settings: TapstreamLogger logger, TapstreamConversionListener conversionListener
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkTapstream withCredentials:@"TapstreamAccountName", @"TapstreamSDKSecret"];
 
 Facebook
    Params: FacebookAppID (or leave nil to get it from the FacebookAppID key in the Info.plist)
    Settings:
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkFacebook withCredentials:@"FacebookAppID"];
 
 Mixpanel
    Params: MixpanelToken
    Settings: NSUInteger flushInterval, BOOL shouldShowNetworkActivityIndicator
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkMixpanel withCredentials:@"MixpanelToken"];
 
 Parse
    Params: ApplicationID, ClientKey
    Settings:
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkParse withCredentials:@"ParseApplicationID", @"ParseClientKey"];
 
 Localytics
    Params: AppKey
    Settings: BOOL isCollectingAdvertisingIdentifier, NSTimeInterval sessionTimeoutInterval
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkFacebook withCredentials:@"LocalyticsAppKey"];
 
 Amplitude
    Params: APIKey
    Settings: BOOL enableLocationListening, BOOL useAdvertisingIdForDeviceId
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkFacebook withCredentials:@"AmplitudeAPIKey"];
 
 */

#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <FlurrySDK/Flurry.h>
#import <Fabric/Crashlytics.h>
#import <Tapstream/TSTapstream.h>
#import <Facebook-iOS-SDK/FacebookSDK/FacebookSDK.h>
#import <Mixpanel/Mixpanel.h>
#import <Parse/Parse.h>
#import <Localytics/Localytics.h>
#import <Amplitude-iOS/Amplitude.h>

typedef enum {
    GBAnalyticsNetworkGoogleAnalytics = 1,
    GBAnalyticsNetworkFlurry,
    GBAnalyticsNetworkCrashlytics,
    GBAnalyticsNetworkTapstream,
    GBAnalyticsNetworkFacebook,
    GBAnalyticsNetworkMixpanel,
    GBAnalyticsNetworkParse,
    GBAnalyticsNetworkLocalytics,
    GBAnalyticsNetworkAmplitude,
} GBAnalyticsNetwork;

#define kGBAnalyticsFacebookAppIDFromPlist nil

#define kGBAnalyticsAllNetworks [NSSet setWithObjects:@(GBAnalyticsNetworkGoogleAnalytics), @(GBAnalyticsNetworkFlurry), @(GBAnalyticsNetworkCrashlytics), @(GBAnalyticsNetworkTapstream), @(GBAnalyticsNetworkFacebook), @(GBAnalyticsNetworkMixpanel), @(GBAnalyticsNetworkParse), @(GBAnalyticsNetworkLocalytics), @(GBAnalyticsNetworkAmplitude), nil]
