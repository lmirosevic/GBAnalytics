//
//  GBAnalytics.h
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GBAnalyticsNetworks.h"

@interface GBAnalytics : NSObject

+(void)startSessionWithNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials, ...;

+(void)trackEvent:(NSString *)event;
+(void)trackEvent:(NSString *)event withDictionary:(NSDictionary *)dictionary;//only supported by flurry
#define _t(event) ([GBAnalytics trackEvent:event])
#define _td(event, dictionary) ([GBAnalytics trackEvent:event withDictionary:dictionary])

+(void)setDebug:(BOOL)enable;

@end

/* Demo
 
 //Call this in application:didFinishLaunching:withOptions:
 [GBAnalytics startSessionWithNetwork:GBAnalyticsNetworkGoogleAnalytics withCredentials:GOOGLEANALYTICSTRACKINGID];
 
 //Call this anywhere
 _t(@"Pressed buy button");
 _td(@"Bought in-app", @{@"type": @"unlimited"})
 
 Required system frameworks:
 * CoreData
 * SystemConfiguration
 * libz.dylib
 
 Required 3rd party frameworks (make sure project framework search path is correctly set, that framework is added to project as relative, linked against in build phases):
 * BugSense-iOS
 
 Required libraries (add dependency, link, -ObjC linker flag, header search path in superproject):
 * GBToolbox
 
 */


/* Notes

 Bugsense project settings:
 * Strip Linked Symbols During Copy: NO
 * Strip Linked Product: NO
 * Deployment Postprocessing: NO
 * Generate debug symbols: YES
 * Other linker flags: -ObjC
 
 */