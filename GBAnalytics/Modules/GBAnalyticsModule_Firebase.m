//
//  GBAnalyticsModule_Firebase.m
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsModule_Firebase.h"

#import "GBAnalyticsCore.h"

#import <Firebase/Firebase.h>

static NSString * const kGBAnalyticsCredentialsFirebasePListFile = @"kGBAnalyticsCredentialsFirebasePListFile";

@implementation GBAnalyticsModule_Firebase

- (void)configureWithFirebasePlist:(NSString *)plistPath {
    // read in the settings file from the PList into a dictionary
    NSDictionary *firebaseSettings = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // configure ourselves from the firebase settings
    self.APIKey =               firebaseSettings[@"API_KEY"];
    self.bundleID =             firebaseSettings[@"BUNDLE_ID"];
    self.clientID =             firebaseSettings[@"CLIENT_ID"];
    self.trackingID =           firebaseSettings[@"TRACKING_ID"];//param name here not verified
    self.GCMSenderID =          firebaseSettings[@"GCM_SENDER_ID"];
    self.androidClientID =      firebaseSettings[@"ANDROID_CLIENT_ID"];//param name here not verified
    self.googleAppID =          firebaseSettings[@"GOOGLE_APP_ID"];
    self.databaseURL =          firebaseSettings[@"DATABASE_URL"];
    self.deepLinkURLScheme =    firebaseSettings[@"DEEP_LINK_URL_SCHEME"];//param name here not verified
    self.storageBucket =        firebaseSettings[@"STORAGE_BUCKET"];
}

+ (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials args:(va_list)args {
    NSString *FirebaseOptionsPlistName = credentials;
    NSBundle *firebaseOptionsPath = [[NSBundle mainBundle] pathForResource:FirebaseOptionsPlistName ofType:@"plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:firebaseOptionsPath]) {
        [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkFirebase)] = @{kGBAnalyticsCredentialsFirebasePListFile: FirebaseOptionsPlistName};
        
        // commit the settings from the plist file into the GBAnalytics Firebase settings object
        [[GBAnalyticsManager sharedManager].settings.Firebase configureWithFirebasePlist:firebaseOptionsPath];
        
        // create FIROptions by reading the values from the configuration file
        FIROptions *options = [[FIROptions alloc] initWithGoogleAppID:[GBAnalyticsManager sharedManager].settings.Firebase.googleAppID
                                                             bundleID:[GBAnalyticsManager sharedManager].settings.Firebase.bundleID
                                                          GCMSenderID:[GBAnalyticsManager sharedManager].settings.Firebase.GCMSenderID
                                                               APIKey:[GBAnalyticsManager sharedManager].settings.Firebase.APIKey
                                                             clientID:[GBAnalyticsManager sharedManager].settings.Firebase.clientID
                                                           trackingID:[GBAnalyticsManager sharedManager].settings.Firebase.trackingID
                                                      androidClientID:[GBAnalyticsManager sharedManager].settings.Firebase.androidClientID
                                                          databaseURL:[GBAnalyticsManager sharedManager].settings.Firebase.databaseURL
                                                        storageBucket:[GBAnalyticsManager sharedManager].settings.Firebase.storageBucket
                                                    deepLinkURLScheme:[GBAnalyticsManager sharedManager].settings.Firebase.deepLinkURLScheme];
        
        // configure Firebase with our FIROptions, that we made from the plist file
        [FIRApp configureWithOptions:options];
    }
    else [GBAnalyticsManager signalInvalidCredentialsForNetwork:network additionalInfo:@"You must pass in the name of the PList file, without the extension, and ensure that it is located in the main bundle, e.g. @\"GoogleService-Info\"."];
}

+ (void)trackEvent:(NSString *)event {
    [self trackEvent:event withParameters:nil];
}

+ (void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
    [FIRAnalytics logEventWithName:[self sanitisedEventName:event] parameters:parameters];
}

#pragma mark - Private

+ (NSString *)sanitisedEventName:(NSString *)eventName {
    NSMutableCharacterSet *allowedCharacterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [allowedCharacterSet addCharactersInString:@"_"];
    
    return [self stringByReplacingCharactersInSet:allowedCharacterSet.invertedSet fromString:eventName withString:@"_"];
}

+ (NSString *)stringByReplacingCharactersInSet:(NSCharacterSet *)charSet fromString:(NSString *)originalString withString:(NSString *)replacementString {
    NSMutableString *s = [NSMutableString stringWithCapacity:originalString.length];
    for (NSUInteger i = 0; i < originalString.length; ++i) {
        unichar c = [originalString characterAtIndex:i];
        if (![charSet characterIsMember:c]) {
            [s appendFormat:@"%C", c];
        } else {
            [s appendString:replacementString];
        }
    }
    return s;
}

@end
