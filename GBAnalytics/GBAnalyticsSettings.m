//
//  GBAnalyticsSettings.m
//  GBAnalytics
//
//  Created by Luka Mirosevic on 12/12/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import "GBAnalyticsSettings.h"

@implementation GBAnalyticsSettings

-(id)init {
    if (self = [super init]) {
        self.GoogleAnalytics = [GBAnalyticsGoogleAnalyticsSettings new];
        self.Flurry = [GBAnalyticsFlurrySettings new];
        self.Crashlytics = [GBAnalyticsCrashlyticsSettings new];
        self.Tapstream = [GBAnalyticsTapstreamSettings new];
        self.Facebook = [GBAnalyticsFacebookSettings new];
        self.Mixpanel = [GBAnalyticsMixpanelSettings new];
    }
    
    return self;
}

@end

#pragma mark - Google Analytics

static NSTimeInterval const kDefaultGoogleAnalyticsDispatchInterval = 10;
static BOOL const kDefaultGoogleAnalyticsShouldTrackUncaughtExceptions = NO;

@implementation GBAnalyticsGoogleAnalyticsSettings

-(id)init {
    if (self = [super init]) {
        self.dispatchInterval = kDefaultGoogleAnalyticsDispatchInterval;
        self.shouldTrackUncaughtExceptions = kDefaultGoogleAnalyticsShouldTrackUncaughtExceptions;
    }
    
    return self;
}

@end

#pragma mark - Flurry

@implementation GBAnalyticsFlurrySettings

-(id)init {
    if (self = [super init]) {
    }
    
    return self;
}

@end

#pragma mark - Crashlytics

@implementation GBAnalyticsCrashlyticsSettings

-(id)init {
    if (self = [super init]) {
    }
    
    return self;
}

@end

#pragma mark - Tapstream

static TapstreamLogger const kDefaultTapstreamLogger = nil;
static TapstreamConversionListener const kDefaultTapstreamConversionListener = nil;

@implementation GBAnalyticsTapstreamSettings

-(id)init {
    if (self = [super init]) {
        self.logger = kDefaultTapstreamLogger;
        self.conversionListener = kDefaultTapstreamConversionListener;
    }
    
    return self;
}

@end

#pragma mark - Facebook

@implementation GBAnalyticsFacebookSettings

-(id)init {
    if (self = [super init]) {
    }
    
    return self;
}

@end

#pragma mark - Mixpanel

static NSTimeInterval const kDefaultMixpanelFlushInterval = 10;
static BOOL const kDefaultMixpanelShouldShowNetworkActivityIndicator = NO;

@implementation GBAnalyticsMixpanelSettings

-(id)init {
    if (self = [super init]) {
        self.flushInterval = kDefaultMixpanelFlushInterval;
        self.shouldShowNetworkActivityIndicator = kDefaultMixpanelShouldShowNetworkActivityIndicator;
    }
    
    return self;
}

@end
