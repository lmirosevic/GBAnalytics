//
//  GBAnalyticsModule_Firebase.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GBAnalyticsModule.h"

@interface GBAnalyticsModule_Firebase : NSObject <GBAnalyticsModule>

/**
 Configure these properties with a Firebase plist file. This will only set values which have not been set before, i.e. no overwriting of non-nil values.
 */
- (void)configureWithFirebasePlist:(NSString *)plistPath;

@property (nonatomic, copy) NSString                                        *APIKey;
@property (nonatomic, copy) NSString                                        *bundleID;
@property (nonatomic, copy) NSString                                        *clientID;
@property (nonatomic, copy) NSString                                        *trackingID;
@property (nonatomic, copy) NSString                                        *GCMSenderID;
@property (nonatomic, copy) NSString                                        *androidClientID;
@property (nonatomic, copy) NSString                                        *googleAppID;
@property (nonatomic, copy) NSString                                        *databaseURL;
@property (nonatomic, copy) NSString                                        *deepLinkURLScheme;
@property (nonatomic, copy) NSString                                        *storageBucket;

@end

@interface GBAnalyticsSettings (Firebase)

@property (strong, nonatomic, readonly) GBAnalyticsModule_Firebase          *Firebase;

@end
