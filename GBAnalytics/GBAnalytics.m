//
//  GBAnalytics.m
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2015 Goonbee. All rights reserved.
//

#import "GBAnalytics.h"

#import <AdSupport/AdSupport.h>

#define IsValidString(string) (([string isKindOfClass:NSString.class] && ((NSString *)string).length > 0) ? YES : NO)

NSString * const kGBAnalyticsDefaultEventRoute =                                        @"kGBAnalyticsDefaultEventRoute";

#if !DEBUG
static BOOL const kProductionBuild =                                                    YES;
#else
static BOOL const kProductionBuild =                                                    NO;
#endif

// Google Analytics
static NSString * const kGBAnalyticsCredentialsGoogleAnalyticsTrackingIDs =             @"kGBAnalyticsCredentialsGoogleAnalyticsTrackingIDs";
static NSString * const kGBAnalyticsGoogleAnalyticsActionlessEventActionString =        @"Plain";

// Flurry
static NSString * const kGBAnalyticsCredentialsFlurryAPIKey =                           @"kGBAnalyticsCredentialsFlurryAPIKey";

// Crashlytics
static NSString * const kGBAnalyticsCredentialsCrashlyticsAPIKey =                      @"kGBAnalyticsCredentialsCrashlyticsAPIKey";

// Tapstream
static NSString * const kGBAnalyticsCredentialsTapstreamAccountName =                   @"kGBAnalyticsCredentialsTapstreamAccountName";
static NSString * const kGBAnalyticsCredentialsTapstreamSDKSecret =                     @"kGBAnalyticsCredentialsTapstreamSDKSecret";

// Facebook
static NSString * const kGBAnalyticsCredentialsFacebookAppID =                          @"kGBAnalyticsCredentialsFacebookAppID";

// Mixpanel
static NSString * const kGBAnalyticsCredentialsMixpanelToken =                          @"kGBAnalyticsCredentialsMixpanelToken";

// Parse Analytics
static NSString * const kGBAnalyticsCredentialsParseApplicationID =                     @"kGBAnalyticsCredentialsParseApplicationID";
static NSString * const kGBAnalyticsCredentialsParseClientKey =                         @"kGBAnalyticsCredentialsParseClientKey";

// Localytics
static NSString * const kGBAnalyticsCredentialsLocalyticsAppKey =                       @"kGBAnalyticsCredentialsLocalyticsAppKey";

// Amplitude
static NSString * const kGBAnalyticsCredentialsAmplitudeAPIKey =                        @"kGBAnalyticsCredentialsAmplitudeAPIKey";

typedef void(^ApplicationDidGenerateNotificationBlock)(NSString *notificationName, NSDictionary *userInfo);

BOOL _GBAnalyticsEnabled() {
    return GBAnalytics.force || kProductionBuild;
}

@interface GBAnalyticsManager ()

@property (strong, nonatomic) NSMutableDictionary                                       *connectedAnalyticsNetworks;
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
    
    // don't send data if it's not enabled
    if (GBAnalyticsEnabled) {
        void(^invalidCredentialsErrorHandler)(void) = ^{
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"GBAnalytics Error: Didn't pass valid credentials for %@", [self.class _networkNameForNetwork:network]] userInfo:nil];
        };
    
        va_list args;
        va_start(args, credentials);

        switch (network) {
            case GBAnalyticsNetworkGoogleAnalytics: {
                NSString *TrackingID = credentials;
                
                if (IsValidString(TrackingID)) {
                    // support for multiple tracking ids
                    NSArray *trackingIDs = self.connectedAnalyticsNetworks[@(GBAnalyticsNetworkGoogleAnalytics)][kGBAnalyticsCredentialsGoogleAnalyticsTrackingIDs];
                    // if trackingIDs is nil then it's initalization of GA
                    if (!trackingIDs) {
                        trackingIDs = [NSArray new];
                    }
                    
                    trackingIDs = [trackingIDs arrayByAddingObject:TrackingID];
                    self.connectedAnalyticsNetworks[@(GBAnalyticsNetworkGoogleAnalytics)] = @{kGBAnalyticsCredentialsGoogleAnalyticsTrackingIDs: trackingIDs};
                    
                    // apply GA settings
                    [GAI sharedInstance].dispatchInterval = self.settings.GoogleAnalytics.dispatchInterval;
                    [GAI sharedInstance].trackUncaughtExceptions = self.settings.GoogleAnalytics.shouldTrackUncaughtExceptions;
                    
                    // if it's the first tracker it will be set as GA defaultTracker
                    [[GAI sharedInstance] trackerWithTrackingId:TrackingID];
                }
                else invalidCredentialsErrorHandler();
            } break;
                
            case GBAnalyticsNetworkFlurry: {
                NSString *APIKey = credentials;
                
                if (IsValidString(APIKey)) {
                    self.connectedAnalyticsNetworks[@(GBAnalyticsNetworkFlurry)] = @{kGBAnalyticsCredentialsFlurryAPIKey: APIKey};
                    
                    [Flurry startSession:APIKey];
                }
                else invalidCredentialsErrorHandler();
            } break;
                
            case GBAnalyticsNetworkCrashlytics: {
                NSString *APIKey = credentials;
                
                if (IsValidString(APIKey)) {
                    self.connectedAnalyticsNetworks[@(GBAnalyticsNetworkCrashlytics)] = @{kGBAnalyticsCredentialsCrashlyticsAPIKey: APIKey};
                    
                    [Crashlytics startWithAPIKey:APIKey];
                }
                else invalidCredentialsErrorHandler();
            } break;
                
            case GBAnalyticsNetworkTapstream: {
                NSString *AccountName = credentials;
                NSString *SDKSecret = va_arg(args, NSString *);
                
                if (IsValidString(AccountName) && IsValidString(SDKSecret)) {
                    self.connectedAnalyticsNetworks[@(GBAnalyticsNetworkTapstream)] = @{kGBAnalyticsCredentialsTapstreamAccountName: AccountName, kGBAnalyticsCredentialsTapstreamSDKSecret: SDKSecret};
                    
                    [TSLogging setLogger:self.settings.Tapstream.logger];
                    TSConfig *config = [TSConfig configWithDefaults];
                    [TSTapstream createWithAccountName:AccountName developerSecret:SDKSecret config:config];
                }
                else invalidCredentialsErrorHandler();
            } break;
                
            case GBAnalyticsNetworkFacebook: {
                NSString *FBAppID = credentials ?: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
                
                if (IsValidString(FBAppID)) {
                    self.connectedAnalyticsNetworks[@(GBAnalyticsNetworkFacebook)] = @{kGBAnalyticsCredentialsFacebookAppID: FBAppID};
                    
                    [FBSettings setDefaultAppID:FBAppID];
                }
                else invalidCredentialsErrorHandler();
            } break;
                
            case GBAnalyticsNetworkMixpanel: {
                NSString *Token = credentials;
                
                if (IsValidString(Token)) {
                    self.connectedAnalyticsNetworks[@(GBAnalyticsNetworkMixpanel)] = @{kGBAnalyticsCredentialsMixpanelToken: Token};
                    
                    [Mixpanel sharedInstanceWithToken:Token];
                    [Mixpanel sharedInstance].flushInterval = self.settings.Mixpanel.flushInterval;
                    [Mixpanel sharedInstance].showNetworkActivityIndicator = self.settings.Mixpanel.shouldShowNetworkActivityIndicator;
                }
                else invalidCredentialsErrorHandler();
            } break;
                
            case GBAnalyticsNetworkParse: {
                NSString *ApplicationID = credentials;
                NSString *ClientKey = va_arg(args, NSString *);
                
                if (IsValidString(ApplicationID) && IsValidString(ClientKey)) {
                    self.connectedAnalyticsNetworks[@(GBAnalyticsNetworkParse)] = @{kGBAnalyticsCredentialsParseApplicationID: ApplicationID, kGBAnalyticsCredentialsParseClientKey: ClientKey};
                    
                    [Parse setApplicationId:ApplicationID clientKey:ClientKey];
                    
                    [self _addHandlerForApplicationNotification:^(NSString *notificationName, NSDictionary *userInfo) {
                        if ([notificationName isEqualToString:UIApplicationDidFinishLaunchingNotification]) {
                            [PFAnalytics trackAppOpenedWithLaunchOptions:userInfo];
                        }
                    }];
                }
                else invalidCredentialsErrorHandler();
            } break;
                
            case GBAnalyticsNetworkLocalytics: {
                NSString *AppKey = credentials;
                
                if (IsValidString(AppKey)) {
                    self.connectedAnalyticsNetworks[@(GBAnalyticsNetworkLocalytics)] = @{kGBAnalyticsCredentialsLocalyticsAppKey: AppKey};
                    
                    [Localytics integrate:AppKey];
                    
                    [Localytics setCollectAdvertisingIdentifier:self.settings.Localytics.isCollectingAdvertisingIdentifier];
                    [Localytics setSessionTimeoutInterval:self.settings.Localytics.sessionTimeoutInterval];
                    
                    
                    [self _addHandlerForApplicationNotification:^(NSString *notificationName, NSDictionary *userInfo) {
                        if ([notificationName isEqualToString:UIApplicationDidBecomeActiveNotification] ||
                            [notificationName isEqualToString:UIApplicationWillEnterForegroundNotification]) {
                            [Localytics openSession];
                            [Localytics upload];
                        }
                        else if ([notificationName isEqualToString:UIApplicationWillResignActiveNotification] ||
                                 [notificationName isEqualToString:UIApplicationDidEnterBackgroundNotification] ||
                                 [notificationName isEqualToString:UIApplicationWillTerminateNotification]) {
                            [Localytics closeSession];
                            [Localytics upload];
                        }
                    }];
                }
                else invalidCredentialsErrorHandler();
            } break;
                
            case GBAnalyticsNetworkAmplitude: {
                NSString *APIKey = credentials;
                
                if (IsValidString(APIKey)) {
                    self.connectedAnalyticsNetworks[@(GBAnalyticsNetworkAmplitude)] = @{kGBAnalyticsCredentialsAmplitudeAPIKey: APIKey};
                    
                    // for Amplitude, it's important to apply the settings first, before initialising it
                    if (self.settings.Amplitude.useAdvertisingIdForDeviceId) {
                        [Amplitude useAdvertisingIdForDeviceId];
                    }
                    
                    if (self.settings.Amplitude.enableLocationListening) {
                        [Amplitude enableLocationListening];
                    }
                    else {
                        [Amplitude disableLocationListening];
                    }
                    
                    [Amplitude initializeApiKey:APIKey];
                }
                else invalidCredentialsErrorHandler();
            } break;
                
            default: {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"GBAnalytics Error: Tried to connect to invalid network: %@", [self.class _networkNameForNetwork:network]] userInfo:nil];
            } break;
        }
        
        va_end(args);
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

#pragma mark - Private

- (void)_addHandlerForApplicationNotification:(ApplicationDidGenerateNotificationBlock)block {
    // without a block it's all a moo point
    if (block) {
        [self.applicationNotificationDelegateHandlers addObject:[block copy]];
    }
}

- (void)_applicationDidGenerateNotification:(NSNotification *)notification {
    // call our handlers
    for (ApplicationDidGenerateNotificationBlock block in self.applicationNotificationDelegateHandlers) {
        block(notification.name, notification.userInfo);
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

+ (NSString *)_networkNameForNetwork:(GBAnalyticsNetwork)network {
    switch (network) {
        case GBAnalyticsNetworkGoogleAnalytics: {
            return @"Google Analytics";
        } break;
            
        case GBAnalyticsNetworkFlurry: {
            return @"Flurry";
        } break;
            
        case GBAnalyticsNetworkCrashlytics: {
            return @"Crashlytics";
        } break;
            
        case GBAnalyticsNetworkTapstream: {
            return @"Tapstream";
        } break;
            
        case GBAnalyticsNetworkFacebook: {
            return @"Facebook";
        } break;
            
        case GBAnalyticsNetworkMixpanel: {
            return @"Mixpanel";
        } break;
            
        case GBAnalyticsNetworkParse: {
            return @"Parse";
        } break;
            
        case GBAnalyticsNetworkLocalytics: {
            return @"Localytics";
        } break;
            
        case GBAnalyticsNetworkAmplitude: {
            return @"Amplitude";
        } break;
    }
}

+ (NSString *)_formatEventNameForFacebook:(NSString *)eventName {
    NSMutableString *formattedName = [eventName mutableCopy];
    
    [formattedName replaceOccurrencesOfString:@"(" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formattedName.length)];
    [formattedName replaceOccurrencesOfString:@")" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formattedName.length)];
    [formattedName replaceOccurrencesOfString:@":" withString:@"-" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formattedName.length)];
    if (formattedName.length > 40) [formattedName deleteCharactersInRange:NSMakeRange(40, formattedName.length - 40)];
    
    return [formattedName copy];
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
    
    // warn if there are no routes associated here
    if (![self _areNetworksAssociatedWithThisRoute]) [GBAnalyticsManager _debugWarningString:[NSString stringWithFormat:@"There are no networks associated with the route %@, the following event was not sent: %@", self.route, event] force:YES];
    
    // don't send data if it's not enabled
    if (GBAnalyticsEnabled) {
        if (IsValidString(event)) {
            for (NSNumber *number in [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks) {
                GBAnalyticsNetwork network = [number intValue];
                
                // if it's not routing to this network, then skip it and go on to the next connected network
                if (![self _shouldRouteToNetwork:network]) {
                    continue;
                }
                
                switch (network) {
                    case GBAnalyticsNetworkGoogleAnalytics: {
                        NSArray *trackingIDs = [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkGoogleAnalytics)][kGBAnalyticsCredentialsGoogleAnalyticsTrackingIDs];
                        for (NSString *trackingID in trackingIDs) {
                            id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:trackingID];
                            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:event action:kGBAnalyticsGoogleAnalyticsActionlessEventActionString label:nil value:nil] build]];
                        }
                    } break;
                        
                    case GBAnalyticsNetworkFlurry: {
                        [Flurry logEvent:event];
                    } break;
                        
                    case GBAnalyticsNetworkCrashlytics: {
                        // noop, doesn't support events
                    } break;

                    case GBAnalyticsNetworkTapstream: {
                        [[TSTapstream instance] fireEvent:[TSEvent eventWithName:event oneTimeOnly:NO]];
                    } break;
                        
                    case GBAnalyticsNetworkFacebook: {
                        [FBAppEvents logEvent:[GBAnalyticsManager _formatEventNameForFacebook:event]];
                    } break;
                        
                    case GBAnalyticsNetworkMixpanel: {
                        [[Mixpanel sharedInstance] track:event];
                    } break;
                        
                    case GBAnalyticsNetworkParse: {
                        // we need to remove spaces from the event name
                        NSString *safeEventName = [event stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                        
                        // send the actual event
                        [PFAnalytics trackEvent:safeEventName];
                    } break;
                        
                    case GBAnalyticsNetworkLocalytics: {
                        [Localytics tagEvent:event];
                    } break;
                        
                    case GBAnalyticsNetworkAmplitude: {
                        [Amplitude logEvent:event];
                    } break;
                }
            }
        }
        else {
            [GBAnalyticsManager _debugErrorString:@"trackEvent: has not been called with a valid non-empty string" force:YES];
        }
    }
}

- (void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
    [GBAnalyticsManager _debugLogString:event withDictionary:parameters force:NO];
    
    // warn if there are no routes associated here
    if (![self _areNetworksAssociatedWithThisRoute]) [GBAnalyticsManager _debugWarningString:[NSString stringWithFormat:@"There are no networks associated with the route %@, the following event was not sent: %@", self.route, event] force:YES];
    
    // don't send data if it's not enabled
    if (GBAnalyticsEnabled) {
        if (IsValidString(event)) {
            // if the dictionary is not a dict or empty, just forward the call to the simple trackEvent: and thereby discard the event nonsense
            if (![parameters isKindOfClass:[NSDictionary class]] || parameters.count == 0) {
                [self trackEvent:event];
                return;
            }
            
            for (NSNumber *number in [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks) {
                GBAnalyticsNetwork network = [number intValue];
                
                // if it's not routing to this network, then skip it and go on to the next connected network
                if (![self _shouldRouteToNetwork:network]) {
                    continue;
                }
                
                switch (network) {
                    case GBAnalyticsNetworkGoogleAnalytics: {
                        // for each key/value pair in the dict, send a separate event with a corresponding action/label pair
                        NSArray *trackingIDs = [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks[@(GBAnalyticsNetworkGoogleAnalytics)][kGBAnalyticsCredentialsGoogleAnalyticsTrackingIDs];
                        for (NSString *trackingID in trackingIDs) {
                            for (NSString *key in parameters) {
                                id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:trackingID];
                                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:event action:key label:parameters[key] value:nil] build]];
                            }
                        }
                    } break;
                        
                    case GBAnalyticsNetworkFlurry: {
                        [Flurry logEvent:event withParameters:parameters];
                    } break;
                        
                    case GBAnalyticsNetworkCrashlytics: {
                        // noop, doesn't support events
                    } break;
                        
                    case GBAnalyticsNetworkTapstream: {
                        TSEvent *e = [TSEvent eventWithName:event oneTimeOnly:NO];
                        for (NSString *key in parameters) {
                            [e addValue:parameters[key] forKey:key];
                        }
                        
                        [[TSTapstream instance] fireEvent:e];
                    } break;
                        
                    case GBAnalyticsNetworkFacebook: {
                        [FBAppEvents logEvent:[GBAnalyticsManager _formatEventNameForFacebook:event] parameters:parameters];
                    } break;
                        
                    case GBAnalyticsNetworkMixpanel: {
                        [[Mixpanel sharedInstance] track:event properties:parameters];
                    } break;
                        
                    case GBAnalyticsNetworkParse: {
                        // we need to remove spaces from the event name
                        NSString *safeEventName = [event stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                        
                        // we need to flatten the dictionary because otherwise it causes an error
                        NSMutableDictionary *flatDictionary = [NSMutableDictionary new];
                        for (NSString *key in parameters) {
                            id value = parameters[key];

                            // KEY
                            NSString *keyString;
                            
                            // force as string
                            keyString = [key description];
                            
                            // VALUE
                            NSString *valueString;
                            
                            // try json first
                            if ([NSJSONSerialization isValidJSONObject:value]) {
                                NSError *error;
                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value
                                                                                   options:0
                                                                                     error:&error];
                                
                                // we got some data and no error was returned
                                if (jsonData && !error) {
                                    // we update the string
                                    valueString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                }
                            }
                            
                            // JSON didn't work
                            if (!valueString) {
                                
                                valueString = [value description];
                            }
                            
                            // put it into the flat dictionary
                            flatDictionary[keyString] = valueString;
                        }
                        
                        // send the actual data
                        [PFAnalytics trackEvent:safeEventName dimensions:flatDictionary];
                    } break;
                        
                    case GBAnalyticsNetworkLocalytics: {
                        [Localytics tagEvent:event attributes:parameters];
                    } break;
                        
                    case GBAnalyticsNetworkAmplitude: {
                        [Amplitude logEvent:event withEventProperties:parameters];
                    } break;
                }
            }
        }
        else {
            [GBAnalyticsManager _debugErrorString:@"trackEvent:withParameters: has not been called with a valid non-empty string" force:YES];
        }
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

