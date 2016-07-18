//
//  GBAnalytics.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsCore.h"

#if !defined(__has_include)
    #error "GBAnalytics.h won't import anything if your compiler doesn't support __has_include. Please import the headers individually."
#else
    #if __has_include("GBAnalyticsModule_GoogleAnalytics.h")
        #import "GBAnalyticsModule_GoogleAnalytics.h"
    #endif

    #if __has_include("GBAnalyticsModule_Flurry.h")
        #import "GBAnalyticsModule_Flurry.h"
    #endif

    #if __has_include("GBAnalyticsModule_Crashlytics.h")
        #import "GBAnalyticsModule_Crashlytics.h"
    #endif

    #if __has_include("GBAnalyticsModule_Answers.h")
        #import "GBAnalyticsModule_Answers.h"
    #endif

    #if __has_include("GBAnalyticsModule_Tapstream.h")
        #import "GBAnalyticsModule_Tapstream.h"
    #endif

    #if __has_include("GBAnalyticsModule_Facebook.h")
        #import "GBAnalyticsModule_Facebook.h"
    #endif

    #if __has_include("GBAnalyticsModule_Mixpanel.h")
        #import "GBAnalyticsModule_Mixpanel.h"
    #endif

    #if __has_include("GBAnalyticsModule_Parse.h")
        #import "GBAnalyticsModule_Parse.h"
    #endif

    #if __has_include("GBAnalyticsModule_Localytics.h")
        #import "GBAnalyticsModule_Localytics.h"
    #endif

    #if __has_include("GBAnalyticsModule_Amplitude.h")
        #import "GBAnalyticsModule_Amplitude.h"
    #endif

    #if __has_include("GBAnalyticsModule_Firebase.h")
        #import "GBAnalyticsModule_Firebase.h"
    #endif
#endif  // defined(__has_include)
