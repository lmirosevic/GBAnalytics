//
//  GBAnalyticsModule_Intercom.m
//  GBAnalytics
//
//  Created by Milutin Tomic on 04/10/2016.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsModule_Intercom.h"

#import "GBAnalyticsCore.h"

#import <Intercom/Intercom.h>

static NSString * const kGBAnalyticsCredentialsIntercomAPIKey =             @"kGBAnalyticsCredentialsIntercomAPIKey";
static NSString * const kGBAnalyticsCredentialsIntercomAppID =              @"kGBAnalyticsCredentialsIntercomAppID";

static BOOL const kDefaultIntercomShouldAutomaticallyRegisterUser =         YES;

@implementation GBAnalyticsModule_Intercom

#pragma mark - CA

- (void)setUserEmail:(NSString *)userEmail {
    _userEmail = userEmail;
    
    [self _registerUser];
}

- (void)setUserId:(NSString *)userId {
    _userId = userId;
    
    [self _registerUser];
}

- (void)setApnsDeviceToken:(NSData *)apnsDeviceToken {
    [Intercom setDeviceToken:apnsDeviceToken];
}

- (void)setShouldAutomaticallyRegisterUser:(BOOL)shouldAutomaticallyRegisterUser {
    _shouldAutomaticallyRegisterUser = shouldAutomaticallyRegisterUser;
    
    // if we have already connected...
    if ([GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkIntercom)]) {
        // tell the caller that this will have no effect
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Setting `shouldAutomaticallyRegisterUser` after the network has already been connected has no effect. You must set this property before calling `connectNetwork:`" userInfo:nil];
    }
}

#pragma mark - API

- (id)init {
    if (self = [super init]) {
        _shouldAutomaticallyRegisterUser = kDefaultIntercomShouldAutomaticallyRegisterUser;
    }

    return self;
}

+ (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials args:(va_list)args {
    NSString *APIKey = credentials;
    NSString *AppID = va_arg(args, NSString *);
    
    if (APIKey.length > 0 && AppID.length > 0) {
        [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkIntercom)] = @{kGBAnalyticsCredentialsIntercomAPIKey: APIKey, kGBAnalyticsCredentialsIntercomAppID: AppID};
        
        // connect to network
        [Intercom setApiKey:APIKey forAppId:AppID];
        
        // register user
        if ([GBAnalyticsManager sharedManager].settings.Intercom.shouldAutomaticallyRegisterUser) {
            [[GBAnalyticsManager sharedManager].settings.Intercom _registerUser];
        }
    }
    else [GBAnalyticsManager signalInvalidCredentialsForNetwork:network];
}

+ (void)trackEvent:(NSString *)event {
    [Intercom logEventWithName:event];
}

+ (void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
    [Intercom logEventWithName:event metaData:parameters];
}

#pragma mark - Private

/**
 *  Registers user with Intercom based on the known user credentials
 */
- (void)_registerUser {
    // check to make sure that we are already connected
    if ([GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkIntercom)]) {
        if (self.userId && self.userEmail) {
            [Intercom registerUserWithUserId:self.userId email:self.userEmail];
        } else if (self.userId) {
            [Intercom registerUserWithUserId:self.userId];
        } else if (self.userEmail) {
            [Intercom registerUserWithEmail:self.userEmail];
        } else {
            [Intercom registerUnidentifiedUser];
        }
    }
}

@end
