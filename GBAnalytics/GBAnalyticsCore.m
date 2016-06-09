//
//  GBAnalyticsCore.m
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalyticsCore.h"

#import "GBAnalyticsModule.h"

#import <AdSupport/AdSupport.h>

NSString * const kGBAnalyticsDefaultEventRoute =                                        @"kGBAnalyticsDefaultEventRoute";

static NSString * const kNetworkNotIncludedErrorFormatString =                          @"GBAnalytics Error: Tried to use a network which hasn't been included. To use this network add the following line to your Podfile: `pod 'GBAnalytics/%1$@'`, or alternatively like so: `pod 'GBAnalytics', subspecs: ['%1$@']`";

#if !DEBUG
static BOOL const kProductionBuild =                                                    YES;
#else
static BOOL const kProductionBuild =                                                    NO;
#endif

BOOL _GBAnalyticsEnabled() {
    return GBAnalytics.force || kProductionBuild;
}

@interface GBAnalyticsManager ()

@property (strong, nonatomic, readwrite) NSMutableDictionary                            *connectedAnalyticsNetworks;
@property (strong, nonatomic, readonly) NSMutableDictionary                             *eventRouters;

@property (strong, nonatomic) NSMutableArray                                            *applicationNotificationDelegateHandlers;

@end

@interface GBAnalyticsEventRouter ()

@property (copy, nonatomic, readwrite) NSString                                         *route;
@property (strong, nonatomic) NSSet                                                     *eventRoutes;

- (id)initWithRoute:(NSString *)route;

@end

@implementation GBAnalyticsManager {
    NSMutableDictionary                                                                 *_eventRouters;
}

#pragma mark - Storage

+ (GBAnalyticsManager *)sharedManager {
    static GBAnalyticsManager *_sharedManager;
    @synchronized(self) {
        if (!_sharedManager) {
            _sharedManager = [GBAnalyticsManager new];
        }
    }
    
    return _sharedManager;
}

- (NSMutableDictionary *)connectedAnalyticsNetworks {
    if (!_connectedAnalyticsNetworks) {
        _connectedAnalyticsNetworks = [NSMutableDictionary new];
    }
    
    return _connectedAnalyticsNetworks;
}

- (NSMutableDictionary *)eventRouters {
    if (!_eventRouters) {
        _eventRouters = [NSMutableDictionary new];
    }

    return _eventRouters;
}

#pragma mark - Initialiser

- (id)init {
    if (self = [super init]) {
        self.isDebugEnabled = NO;

        _settings = [GBAnalyticsSettings new];
        _eventRouters = [NSMutableDictionary new];
        _applicationNotificationDelegateHandlers = [NSMutableArray new];
        
        for (NSString *notificationName in @[UIApplicationDidBecomeActiveNotification,
                                             UIApplicationWillEnterForegroundNotification,
                                             UIApplicationWillResignActiveNotification,
                                             UIApplicationWillTerminateNotification,
                                             UIApplicationDidEnterBackgroundNotification]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidGenerateNotification:) name:notificationName object:nil];
        }
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public API

- (void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials, ... {
    [self.class _debugSessionStartWithNetwork:network force:NO];
    
    Class<GBAnalyticsModule> moduleClass = (Class<GBAnalyticsModule>)NSClassFromString([self.class _classNameForNetwork:network]);
    if (moduleClass) {
        // only send data if we're actually enabled
        if (GBAnalyticsEnabled) {
            va_list args;
            va_start(args, credentials);
            [moduleClass connectNetwork:network withCredentials:credentials args:args];
            va_end(args);
        }
    } else {
        // module not loaded!
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:kNetworkNotIncludedErrorFormatString, [self.class _subspecNameForNetwork:network]] userInfo:nil];
    }
}

- (GBAnalyticsEventRouter *)objectForKeyedSubscript:(NSString *)route {
    if (!self.eventRouters[route]) {
        self.eventRouters[route] = [[GBAnalyticsEventRouter alloc] initWithRoute:route];
    }
    
    return self.eventRouters[route];
}

// these alias the default event router on the manager object
- (id)forwardingTargetForSelector:(SEL)selector {
    if (selector == @selector(routeToNetworks:) ||
        selector == @selector(trackEvent:) ||
        selector == @selector(trackEvent:withParameters:) ||
        selector == @selector(setNetworksToRouteTo:) ||
        selector == @selector(networksToRouteTo)) {
        return self[kGBAnalyticsDefaultEventRoute];
    }
    else {
        return nil;
    }
}

#pragma mark - Module API

+ (void)signalInvalidCredentialsForNetwork:(GBAnalyticsNetwork)network {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"GBAnalytics Error: Didn't pass valid credentials for %@", [self _networkNameForNetwork:network]] userInfo:nil];
}

- (void)addHandlerForApplicationNotification:(ApplicationDidGenerateNotificationBlock)block {
    // without a block it's all a moo point
    if (block) {
        [self.applicationNotificationDelegateHandlers addObject:[block copy]];
    }
}

#pragma mark - Debug Util

+ (void)_debugSessionStartWithNetwork:(GBAnalyticsNetwork)network force:(BOOL)force {
    [self _debugLogString:[NSString stringWithFormat:@"Started session with analytics network: %@", [self.class _networkNameForNetwork:network]] force:force];
}

+ (void)_debugErrorString:(NSString *)warning force:(BOOL)force {
    if ([GBAnalyticsManager sharedManager].isDebugEnabled || force) {
        [self _debugType:@"Error" withString:warning];
    }
}

+ (void)_debugWarningString:(NSString *)warning force:(BOOL)force {
    if ([GBAnalyticsManager sharedManager].isDebugEnabled || force) {
        [self _debugType:@"Warning" withString:warning];
    }
}

+ (void)_debugLogString:(NSString *)event force:(BOOL)force {
    if ([GBAnalyticsManager sharedManager].isDebugEnabled || force) {
        [self _debugType:@"Log" withString:event];
    }
}

+ (void)_debugLogString:(NSString *)event withDictionary:(NSDictionary *)dictionary force:(BOOL)force {
    if ([GBAnalyticsManager sharedManager].isDebugEnabled || force) {
        [self _debugType:@"Log" withString:event withDictionary:dictionary];
    }
}

+ (void)_debugType:(NSString *)type withString:(NSString *)event {
    NSLog(@"GBAnalytics %@: %@", type, event);
}

+ (void)_debugType:(NSString *)type withString:(NSString *)event withDictionary:(NSDictionary *)dictionary {
    NSLog(@"GBAnalytics %@: %@, %@", type, event, dictionary);
}

#pragma mark - Util

- (void)_applicationDidGenerateNotification:(NSNotification *)notification {
    // call our handlers
    for (ApplicationDidGenerateNotificationBlock block in self.applicationNotificationDelegateHandlers) {
        block(notification.name, notification.userInfo);
    }
}

+ (NSString *)_networkNameForNetwork:(GBAnalyticsNetwork)network {
    return NetworkNameForNetwork(network);
}

+ (NSString *)_programmaticIdentifierForNetwork:(GBAnalyticsNetwork)network {
    // remove the spaces from the network names
    return [[self _networkNameForNetwork:network] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (NSString *)_subspecNameForNetwork:(GBAnalyticsNetwork)network {
    return [self _programmaticIdentifierForNetwork:network];
}

+ (NSString *)_classNameForNetwork:(GBAnalyticsNetwork)network {
    return [NSString stringWithFormat:@"GBAnalyticsModule_%@", [self _programmaticIdentifierForNetwork:network]];
}

@end

@implementation GBAnalyticsEventRouter

#pragma mark - Life

- (id)initWithRoute:(NSString *)route {
    if (self = [super init]) {
        self.route = route;
        
        if ([route isEqualToString:kGBAnalyticsDefaultEventRoute]) {
            _eventRoutes = kGBAnalyticsAllNetworks;
        }
    }
    
    return self;
}

#pragma mark - Public API

- (void)routeToNetworks:(GBAnalyticsNetwork)network, ... NS_REQUIRES_NIL_TERMINATION {
    // convert varargs into set
    va_list args;
    GBAnalyticsNetwork aNetwork;
    NSMutableSet *networks = [NSMutableSet new];
    [networks addObject:@(network)];
    va_start(args, network);
    while ((aNetwork = va_arg(args, GBAnalyticsNetwork))) {
        [networks addObject:@(aNetwork)];
    }
    va_end(args);
    
    // set the actual routes
    self.networksToRouteTo = networks;
}

- (NSSet *)networksToRouteTo {
    // we return a copy, and never nil
    return [self.eventRoutes copy] ?: [NSSet new];
}

- (void)setNetworksToRouteTo:(NSSet *)networksToRouteTo {
    if (GBAnalyticsEnabled) {
        // for any network that isn't enabled yet, show a warning
        for (NSNumber *networkNumber in networksToRouteTo) {
            if (![GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[networkNumber]) {
                [GBAnalyticsManager _debugWarningString:[NSString stringWithFormat:@"You are adding the network \"%@\" to the route \"%@\" which is not connected yet. Your events will NOT be sent until you connect the network using `[GBAnalytics connectNetwork:withCredentials:]`. Connect networks before settings up routes to silence this warning.", [GBAnalyticsManager _networkNameForNetwork:[networkNumber intValue]], self.route] force:YES];
            }
        }
    }
    
    self.eventRoutes = networksToRouteTo;
}

- (void)trackEvent:(NSString *)event {
    [GBAnalyticsManager _debugLogString:event force:NO];
    [self _trackEvent:event withParameters:nil];
}

- (void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
    [GBAnalyticsManager _debugLogString:event withDictionary:parameters force:NO];
    [self _trackEvent:event withParameters:nil];
}

- (void)_trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
    // warn if there are no routes associated here
    if (![self _areNetworksAssociatedWithThisRoute]) [GBAnalyticsManager _debugWarningString:[NSString stringWithFormat:@"There are no networks associated with the route %@, the following event was not sent: %@", self.route, event] force:YES];
    
    // make sure first of all that it's a valid string
    if (event.length > 0) {
        for (NSNumber *number in [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks) {
            GBAnalyticsNetwork network = [number intValue];
            
            // if it's not routing to this network, then skip it and go on to the next connected network
            if (![self _shouldRouteToNetwork:network]) {
                continue;
            }
            
            Class<GBAnalyticsModule> moduleClass = (Class<GBAnalyticsModule>)NSClassFromString([GBAnalyticsManager _classNameForNetwork:network]);
            if (moduleClass) {
                // only send data if we're actually enabled
                if (GBAnalyticsEnabled) {
                    // if the dictionary is not a dict or empty, just forward the call to the simple trackEvent: and thereby discard the event nonsense
                    if (![parameters isKindOfClass:[NSDictionary class]] || parameters.count == 0) {
                        [moduleClass trackEvent:event];
                    } else {
                        [moduleClass trackEvent:event withParameters:parameters];
                    }
                }
            } else {
                // module not loaded!
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:kNetworkNotIncludedErrorFormatString, [self.class _subspecNameForNetwork:network]] userInfo:nil];
            }
        }
    }
    else {
        [GBAnalyticsManager _debugErrorString:@"trackEvent:(withParameters:) has not been called with a valid non-empty string" force:YES];
    }
}

#pragma mark - Private

- (BOOL)_shouldRouteToNetwork:(GBAnalyticsNetwork)network {
    return [self.eventRoutes containsObject:@(network)];
}

- (BOOL)_areNetworksAssociatedWithThisRoute {
    return self.eventRoutes.count > 0;
}

@end

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

- (NSObject *)_settingsObjectForSelector:(SEL)selector {
    NSString *networkName = NSStringFromSelector(selector);// the network name is the same as the property name
    Class<GBAnalyticsModule> moduleClass = NSClassFromString([NSString stringWithFormat:@"GBAnalyticsModule_%@", NSStringFromSelector(selector)]);
    
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
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:kNetworkNotIncludedErrorFormatString, networkName] userInfo:nil];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [super methodSignatureForSelector:@selector(_settingsObjectForSelector:)];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    // we get the old selector out
    SEL oldSelector = invocation.selector;
    
    // redirect the invocation to our single method
    invocation.selector = @selector(_settingsObjectForSelector:);
    
    // we pass the initial selector as the first argument, so our eventual processing method (_settingsObjectForSelector:) knows what was requested
    [invocation setArgument:&oldSelector atIndex:2];
    
    // invoke the selector on ourself, just now on a different method
    [invocation invokeWithTarget:self];
}

@end
