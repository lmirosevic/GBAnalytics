//
//  GBAnalyticsSettings.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 12/12/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>

// GBAnalyticsNetworkGoogleAnalytics = 1,
// GBAnalyticsNetworkFlurry,
// GBAnalyticsNetworkCrashlytics,
// GBAnalyticsNetworkTapstream,
// GBAnalyticsNetworkFacebook,
// GBAnalyticsNetworkMixpanel,
// GBAnalyticsNetworkParse,
// GBAnalyticsNetworkLocalytics,
// GBAnalyticsNetworkAmplitude,

@class GBAnalyticsGoogleAnalyticsSettings;
@class GBAnalyticsFlurrySettings;
@class GBAnalyticsCrashlyticsSettings;
@class GBAnalyticsTapstreamSettings;
@class GBAnalyticsFacebookSettings;
@class GBAnalyticsMixpanelSettings;
@class GBAnalyticsParseSettings;
@class GBAnalyticsLocalyticsSettings;
@class GBAnalyticsAmplitudeSettings;

@interface GBAnalyticsSettings : NSObject

@property (strong, nonatomic) GBAnalyticsGoogleAnalyticsSettings		*GoogleAnalytics;
@property (strong, nonatomic) GBAnalyticsFlurrySettings					*Flurry;
@property (strong, nonatomic) GBAnalyticsCrashlyticsSettings			*Crashlytics;
@property (strong, nonatomic) GBAnalyticsTapstreamSettings				*Tapstream;
@property (strong, nonatomic) GBAnalyticsFacebookSettings				*Facebook;
@property (strong, nonatomic) GBAnalyticsMixpanelSettings				*Mixpanel;
@property (strong, nonatomic) GBAnalyticsParseSettings                  *Parse;
@property (strong, nonatomic) GBAnalyticsLocalyticsSettings             *Localytics;
@property (strong, nonatomic) GBAnalyticsAmplitudeSettings              *Amplitude;

@end

#pragma mark - Google Analytics

@interface GBAnalyticsGoogleAnalyticsSettings : NSObject

@property (assign, nonatomic) NSTimeInterval                dispatchInterval;                       //default: 10
@property (assign, nonatomic) BOOL                          shouldTrackUncaughtExceptions;          //default: NO

@end

#pragma mark - Flurry

@interface GBAnalyticsFlurrySettings : NSObject
@end

#pragma mark - Crashlytics

@interface GBAnalyticsCrashlyticsSettings : NSObject
@end

#pragma mark - Tapstream

typedef void(^TapstreamLogger)(int, NSString *);

@interface GBAnalyticsTapstreamSettings : NSObject

@property (copy, nonatomic) TapstreamLogger                 logger;                                 //default: nil

@end

#pragma mark - Facebook

@interface GBAnalyticsFacebookSettings : NSObject
@end

#pragma mark - Mixpanel

@interface GBAnalyticsMixpanelSettings : NSObject

@property (assign, nonatomic) NSUInteger                    flushInterval;                          //default: 10
@property (assign, nonatomic) BOOL                          shouldShowNetworkActivityIndicator;     //default: NO

@end

#pragma mark - Parse

@interface GBAnalyticsParseSettings : NSObject
@end

#pragma mark - Localytics

@interface GBAnalyticsLocalyticsSettings : NSObject

@property (assign, nonatomic) BOOL                          isCollectingAdvertisingIdentifier;      //default: YES
@property (assign, nonatomic) NSTimeInterval                sessionTimeoutInterval;                 //default: 15

@end

#pragma mark - Amplitude

@interface GBAnalyticsAmplitudeSettings : NSObject

@property (assign, nonatomic) BOOL                          enableLocationListening;                //default: YES
@property (assign, nonatomic) BOOL                          useAdvertisingIdForDeviceId;            //default: YES

@end
