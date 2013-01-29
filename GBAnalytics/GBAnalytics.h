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

+(void)enableDebugLogging:(BOOL)enable;

@end

/* Demo
 
 //Call this in application:didFinishLaunching:withOptions:
 [GBAnalytics startSessionWithNetwork:GBAnalyticsNetworkGoogleAnalytics withCredentials:GOOGLEANALYTICSTRACKINGID];
 
 //Call this anywhere
 _t(@"Pressed buy button");
 
 Required frameworks:
 * CoreData
 * SystemConfiguration
 * libz.dylib
 
 */


/* Notes

 Bugsense project settings:
 * Strip Linked Symbols During Copy: NO
 * Strip Linked Product: NO
 * Deployment Postprocessing: NO
 * Generate debug symbols: YES
 * Other linker flags: -ObjC
 
 */