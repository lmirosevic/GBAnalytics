//
//  GBAnalyticsModule_Intercom.m
//  GBAnalytics
//
//  Created by Milutin Tomic on 04/10/2016.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GBAnalyticsModule.h"

@interface GBAnalyticsModule_Intercom : NSObject <GBAnalyticsModule>

/**
 If this is set to YES, GBAnalytics will automatically register a user with Intercom. If you also specify a userEmail and/or userId, it will use those when registering, otherwise it will register an unindentified user.
 
 If you want to change this value, you must do so before calling `connectNetwork`.
 
 Defaults to YES.
 */
@property (assign, nonatomic) BOOL                                          shouldAutomaticallyRegisterUser;


/**
 Setting a userEmail will register the user with an email address with Intercom when connecting the network, if a userId is set as well then both will be used to register the user. If you set this after the network has been connected it will have the effect of re-registering the user with the email address.
 
 If `shouldAutomaticallyRegisterUser` is set to NO then the user is not automatically registered when connecting the Intercom network. Setting this property after connecting will however still register the user.
 */
@property (copy, nonatomic) NSString                                        *userEmail;

/**
 Setting a userId will register the user with a userId with Intercom when connecting the network, if an email is set as well then both will be used to register the user. If you set this after the network has been connected it will have the effect of re-registering the user with the userId.
 
 If `shouldAutomaticallyRegisterUser` is set to NO then the user is not automatically registered when connecting the Intercom network. Setting this property after connecting will however still register the user.
 */
@property (copy, nonatomic) NSString                                        *userId;

@end

@interface GBAnalyticsSettings (Intercom)

@property (strong, nonatomic, readonly) GBAnalyticsModule_Intercom          *Intercom;

@end
