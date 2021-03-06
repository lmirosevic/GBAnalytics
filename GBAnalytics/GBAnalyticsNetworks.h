//
//  GBAnalyticsNetworks.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

/* Networks
 
 Google Analytics
    Params: GoogleAnalyticsTrackingID
    Settings: NSTimeInterval dispatchInterval, BOOL shouldTrackUncaughtExceptions
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkGoogleAnalytics withCredentials:@"GoogleAnalyticsTrackingID"];
 
 Flurry
    Params: FlurryAPIKey
    Settings:
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkFlurry withCredentials:@"FlurryAPIKey"];
 
 Crashlytics
    Params: FabricAPIKey
    Settings:
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkCrashlytics withCredentials:@"FabricAPIKey"];
 
 Answers
    Params: FabricAPIKey
    Settings:
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkAnswers withCredentials:@"FabricAPIKey"];
 
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
 
 Firebase
    Params: PlistName
    Settings:
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkFirebase withCredentials:@"PlistName"];
 
 Intercom
    Params: APIKey, AppID
    Settings:
    Example: [GBAnalytics connectNetwork:GBAnalyticsNetworkIntercom withCredentials:@"APIKey", @"AppID"];
 
 */

#import "GBAnalyticsCore.h"

typedef enum {
    GBAnalyticsNetworkGoogleAnalytics = 1,
    GBAnalyticsNetworkFlurry,
    GBAnalyticsNetworkCrashlytics,
    GBAnalyticsNetworkAnswers,
    GBAnalyticsNetworkTapstream,
    GBAnalyticsNetworkFacebook,
    GBAnalyticsNetworkMixpanel,
    GBAnalyticsNetworkParse,
    GBAnalyticsNetworkLocalytics,
    GBAnalyticsNetworkAmplitude,
    GBAnalyticsNetworkFirebase,
    GBAnalyticsNetworkIntercom,
} GBAnalyticsNetwork;

static inline NSString * NetworkNameForNetwork(GBAnalyticsNetwork network) {
    switch (network) {
        case GBAnalyticsNetworkGoogleAnalytics: {
            return @"Google Analytics";
        } break;
            
        case GBAnalyticsNetworkFlurry: {
            return @"Flurry";
        } break;
            
        case GBAnalyticsNetworkCrashlytics: {
            return @"Crashlytics";
        } break;
            
        case GBAnalyticsNetworkAnswers: {
            return @"Answers";
        } break;
            
        case GBAnalyticsNetworkTapstream: {
            return @"Tapstream";
        } break;
            
        case GBAnalyticsNetworkFacebook: {
            return @"Facebook";
        } break;
            
        case GBAnalyticsNetworkMixpanel: {
            return @"Mixpanel";
        } break;
            
        case GBAnalyticsNetworkParse: {
            return @"Parse";
        } break;
            
        case GBAnalyticsNetworkLocalytics: {
            return @"Localytics";
        } break;
            
        case GBAnalyticsNetworkAmplitude: {
            return @"Amplitude";
        } break;
            
        case GBAnalyticsNetworkFirebase: {
            return @"Firebase";
        } break;
            
        case GBAnalyticsNetworkIntercom: {
            return @"Intercom";
        } break;
            
        /**
         * WARNING: when adding a new network, don't forget to:
         *   1) add the import to the module to GBAnalytics.h
         *   2) add the network to kGBAnalyticsAllNetworks below
         */
    }
}

#define kGBAnalyticsAllNetworks [NSSet setWithObjects:@(GBAnalyticsNetworkGoogleAnalytics), @(GBAnalyticsNetworkFlurry), @(GBAnalyticsNetworkCrashlytics), @(GBAnalyticsNetworkTapstream), @(GBAnalyticsNetworkFacebook), @(GBAnalyticsNetworkMixpanel), @(GBAnalyticsNetworkParse), @(GBAnalyticsNetworkLocalytics), @(GBAnalyticsNetworkAmplitude), @(GBAnalyticsNetworkFirebase), @(GBAnalyticsNetworkIntercom), nil]
