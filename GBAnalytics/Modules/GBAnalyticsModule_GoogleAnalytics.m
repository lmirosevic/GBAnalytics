//
//  GBAnalyticsModule_GoogleAnalytics.m
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsModule_GoogleAnalytics.h"

#import "GBAnalyticsCore.h"

#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>

static NSString * const kGBAnalyticsCredentialsGoogleAnalyticsTrackingIDs =             @"kGBAnalyticsCredentialsGoogleAnalyticsTrackingIDs";
static NSString * const kGBAnalyticsGoogleAnalyticsActionlessEventActionString =        @"Plain";

static NSTimeInterval const kDefaultGoogleAnalyticsDispatchInterval =                   10;
static BOOL const kDefaultGoogleAnalyticsShouldTrackUncaughtExceptions =                NO;

@implementation GBAnalyticsModule_GoogleAnalytics

- (id)init {
    if (self = [super init]) {
        self.dispatchInterval = kDefaultGoogleAnalyticsDispatchInterval;
        self.shouldTrackUncaughtExceptions = kDefaultGoogleAnalyticsShouldTrackUncaughtExceptions;
    }

    return self;
}

+ (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials args:(va_list)args {
    NSString *TrackingID = credentials;
    
    if (TrackingID.length > 0) {
        // support for multiple tracking ids
        NSArray *trackingIDs = [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkGoogleAnalytics)][kGBAnalyticsCredentialsGoogleAnalyticsTrackingIDs];
        // if trackingIDs is nil then it's initalization of GA
        if (!trackingIDs) {
            trackingIDs = [NSArray new];
        }
        
        trackingIDs = [trackingIDs arrayByAddingObject:TrackingID];
        [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkGoogleAnalytics)] = @{kGBAnalyticsCredentialsGoogleAnalyticsTrackingIDs: trackingIDs};
        
        // apply GA settings
        [GAI sharedInstance].dispatchInterval = [GBAnalyticsManager sharedManager].settings.GoogleAnalytics.dispatchInterval;
        [GAI sharedInstance].trackUncaughtExceptions = [GBAnalyticsManager sharedManager].settings.GoogleAnalytics.shouldTrackUncaughtExceptions;
        
        // if it's the first tracker it will be set as GA defaultTracker
        [[GAI sharedInstance] trackerWithTrackingId:TrackingID];
    }
    else [GBAnalyticsManager signalInvalidCredentialsForNetwork:network];
}

+ (void)trackEvent:(NSString *)event {
    NSArray *trackingIDs = [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkGoogleAnalytics)][kGBAnalyticsCredentialsGoogleAnalyticsTrackingIDs];
    for (NSString *trackingID in trackingIDs) {
        id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:trackingID];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:event action:kGBAnalyticsGoogleAnalyticsActionlessEventActionString label:nil value:nil] build]];
    }
}

+ (void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
    // for each key/value pair in the dict, send a separate event with a corresponding action/label pair
    NSArray *trackingIDs = [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkGoogleAnalytics)][kGBAnalyticsCredentialsGoogleAnalyticsTrackingIDs];
    for (NSString *trackingID in trackingIDs) {
        for (NSString *key in parameters) {
            id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:trackingID];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:event action:key label:parameters[key] value:nil] build]];
        }
    }
}

@end
