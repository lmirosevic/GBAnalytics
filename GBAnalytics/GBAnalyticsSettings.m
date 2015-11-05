//
//  GBAnalyticsSettings.m
//  GBAnalytics
//
//  Created by Luka Mirosevic on 12/12/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsSettings.h"

#import "GBAnalyticsModule.h"

@interface GBAnalyticsSettings ()

@property (strong, nonatomic) NSMutableDictionary   *settingsObjects;

@end

@implementation GBAnalyticsSettings

- (id)init {
    if (self = [super init]) {
        self.settingsObjects = [NSMutableDictionary new];
    }
    
    return self;
}

- (NSObject *)settingsObjectForSelector:(SEL)selector {
    NSString *networkName = NSStringFromSelector(selector);// the network name is the same as the property name
    Class<GBAnalyticsModule> moduleClass = NSClassFromString([NSString stringWithFormat:@"GBAnalytics_%@", NSStringFromSelector(selector)]);

    // if we know about the class then it means it has been included and we can use it
    if (moduleClass) {
        // check first if we need to init this network
        if (!self.settingsObjects[networkName]) {
            self.settingsObjects[networkName] = [moduleClass.class new];
        }
        
        return self.settingsObjects[networkName];
    }
    // otherwise chances are that this network has not been included/does not exist
    else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"GBAnalytics Error: Tried to use a network which hasn't been included. To use this network add the following to your Podfile: `pod 'GBAnalytics/%@`", networkName] userInfo:nil];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [NSMethodSignature methodSignatureForSelector:@selector(settingsObjectForSelector:)];
}
    
- (void)forwardInvocation:(NSInvocation *)invocation {
    // redirect the invocation to our single method
    invocation.selector = @selector(settingsObjectForSelector:);
    
    // invoke the selector on ourself, just now on a different method
    [invocation invokeWithTarget:self];
}

@end
