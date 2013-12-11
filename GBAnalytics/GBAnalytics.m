//
//  GBAnalytics.m
//  GBAnalytics
//
//  Created by Luka Mirosevic on 29/01/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import "GBAnalytics.h"

#import "GBAnalytics_OpenUDID.h"
#import <AdSupport/AdSupport.h>

#define IsValidString(string) (([string isKindOfClass:NSString.class] && ((NSString *)string).length > 0) ? YES : NO)

NSString * const kGBAnalyticsDefaultEventRouter =                                       @"kGBAnalyticsDefaultEventRouter";

//Google Analytics
static NSString * const kGBAnalyticsCredentialsGoogleAnalyticsTrackingID =              @"kGBAnalyticsCredentialsGoogleAnalyticsTrackingID";
static NSString * const kGBAnalyticsGoogleAnalyticsActionlessEventActionString =        @"Plain";

//Flurry
static NSString * const kGBAnalyticsCredentialsFlurryAPIKey =                           @"kGBAnalyticsCredentialsFlurryAPIKey";

//Crashlytics
static NSString * const kGBAnalyticsCredentialsCrashlyticsAPIKey =                      @"kGBAnalyticsCredentialsCrashlyticsAPIKey";

//Tapstream
static NSString * const kGBAnalyticsCredentialsTapstreamAccountName =                   @"kGBAnalyticsCredentialsTapstreamAccountName";
static NSString * const kGBAnalyticsCredentialsTapstreamSDKSecret =                     @"kGBAnalyticsCredentialsTapstreamSDKSecret";

//Facebook
static NSString * const kGBAnalyticsCredentialsFacebookAppID =                          @"kGBAnalyticsCredentialsFacebookAppID";

//Mixpanel
static NSString * const kGBAnalyticsCredentialsMixpanelToken =                          @"kGBAnalyticsCredentialsMixpanelToken";


@interface GBAnalyticsManager ()

@property (strong, nonatomic) NSMutableDictionary               *connectedAnalyticsNetworks;
@property (strong, nonatomic, readonly) NSMutableDictionary     *eventRouters;

@end

@interface GBAnalyticsEventRouter ()

@property (copy, nonatomic, readwrite) NSString     *route;
@property (strong, nonatomic) NSArray               *eventRoutes;

-(id)initWithRoute:(NSString *)route;

@end

@implementation GBAnalyticsManager {
    NSMutableDictionary *_eventRouters;
}

#pragma mark - Storage

+(GBAnalyticsManager *)sharedManager {
    static GBAnalyticsManager *_sharedManager;
    @synchronized(self) {
        if (!_sharedManager) {
            _sharedManager = [GBAnalyticsManager new];
        }
    }
    
    return _sharedManager;
}

-(NSMutableDictionary *)connectedAnalyticsNetworks {
    if (!_connectedAnalyticsNetworks) {
        _connectedAnalyticsNetworks = [NSMutableDictionary new];
    }
    
    return _connectedAnalyticsNetworks;
}

-(NSMutableDictionary *)eventRouters {
    if (!_eventRouters) {
        _eventRouters = [NSMutableDictionary new];
    }

    return _eventRouters;
}

#pragma mark - Initialiser

-(id)init {
    if (self = [super init]) {
        self.isDebugEnabled = NO;
        
        _eventRouters = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - Public API (AppStore)

-(void)connectNetwork:(GBAnalyticsNetwork)network withCredentials:(NSString *)credentials, ... {
    [self.class _debugSessionStartWithNetwork:network force:NO];
    
    //don't send data if debugging
//    #if !DEBUG
        void(^invalidCredentialsErrorHandler)(void) = ^{
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"GBAnalytics Error: Didn't pass valid credentials for %@", [self.class _networkNameForNetwork:network]] userInfo:nil];
        };
    
        va_list args;
        va_start(args, credentials);

        switch (network) {
            case GBAnalyticsNetworkGoogleAnalytics: {
                if (IsValidString(credentials)) {
                    self.connectedAnalyticsNetworks[@(GBAnalyticsNetworkGoogleAnalytics)] = @{kGBAnalyticsCredentialsGoogleAnalyticsTrackingID: credentials};
                    
                    [GAI sharedInstance].dispatchInterval = 5;
                    [GAI sharedInstance].trackUncaughtExceptions = NO;
                    [[GAI sharedInstance] trackerWithTrackingId:credentials];
                }
                else invalidCredentialsErrorHandler();
            } break;
                
            case GBAnalyticsNetworkFlurry: {
                if (IsValidString(credentials)) {
                    self.connectedAnalyticsNetworks[@(GBAnalyticsNetworkFlurry)] = @{kGBAnalyticsCredentialsFlurryAPIKey: credentials};
                    
                    [Flurry startSession:credentials];
                }
                else invalidCredentialsErrorHandler();
            } break;
                
            case GBAnalyticsNetworkCrashlytics: {
                if (IsValidString(credentials)) {
                    self.connectedAnalyticsNetworks[@(GBAnalyticsNetworkCrashlytics)] = @{kGBAnalyticsCredentialsCrashlyticsAPIKey: credentials};
                    
                    [Crashlytics startWithAPIKey:credentials];
                }
                else invalidCredentialsErrorHandler();
            } break;
                
            case GBAnalyticsNetworkTapstream: {
                NSString *AccountName = credentials;
                NSString *SDKSecret = va_arg(args, NSString *);
                
                if (IsValidString(AccountName) && IsValidString(SDKSecret)) {
                    self.connectedAnalyticsNetworks[@(GBAnalyticsNetworkTapstream)] = @{kGBAnalyticsCredentialsTapstreamAccountName: AccountName, kGBAnalyticsCredentialsTapstreamSDKSecret: SDKSecret};
                    
                    [TSLogging setLogger:nil];
                    TSConfig *config = [TSConfig configWithDefaults];
                    config.openUdid = [OpenUDID value];
                    if ([ASIdentifierManager class]) config.idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
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
                if (IsValidString(credentials)) {
                    self.connectedAnalyticsNetworks[@(GBAnalyticsNetworkMixpanel)] = @{kGBAnalyticsCredentialsMixpanelToken: credentials};
                    
                    [Mixpanel sharedInstanceWithToken:credentials];
                }
                else invalidCredentialsErrorHandler();
            } break;
                
            default: {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"GBAnalytics Error: Tried to connect to invalid network: %@", [self.class _networkNameForNetwork:network]] userInfo:nil];
            } break;
        }
        
        va_end(args);
//    #endif
}

-(GBAnalyticsEventRouter *)objectForKeyedSubscript:(NSString *)route {
    if (!self.eventRouters[route]) {
        self.eventRouters[route] = [[GBAnalyticsEventRouter alloc] initWithRoute:route];
    }
    
    return self.eventRouters[route];
}

//These alias the default event router
-(id)forwardingTargetForSelector:(SEL)selector {
    if (selector == @selector(routeToNetworks:) ||
        selector == @selector(trackEvent:) ||
        selector == @selector(trackEvent:withParameters:)) {
        return self[kGBAnalyticsDefaultEventRouter];
    }
    else {
        return nil;
    }
}

#pragma mark - Debug Util

+(void)_debugSessionStartWithNetwork:(GBAnalyticsNetwork)network force:(BOOL)force {
    [self _debugLogString:[NSString stringWithFormat:@"Started session with analytics network: %@", [self.class _networkNameForNetwork:network]] force:force];
}

+(void)_debugErrorString:(NSString *)warning force:(BOOL)force {
    if ([GBAnalyticsManager sharedManager].isDebugEnabled || force) {
        [self _debugType:@"Error" withString:warning];
    }
}

+(void)_debugWarningString:(NSString *)warning force:(BOOL)force {
    if ([GBAnalyticsManager sharedManager].isDebugEnabled || force) {
        [self _debugType:@"Warning" withString:warning];
    }
}

+(void)_debugLogString:(NSString *)event force:(BOOL)force {
    if ([GBAnalyticsManager sharedManager].isDebugEnabled || force) {
        [self _debugType:@"Log" withString:event];
    }
}

+(void)_debugLogString:(NSString *)event withDictionary:(NSDictionary *)dictionary force:(BOOL)force {
    if ([GBAnalyticsManager sharedManager].isDebugEnabled || force) {
        [self _debugType:@"Log" withString:event withDictionary:dictionary];
    }
}

+(void)_debugType:(NSString *)type withString:(NSString *)event {
    NSLog(@"GBAnalytics %@: %@", type, event);
}

+(void)_debugType:(NSString *)type withString:(NSString *)event withDictionary:(NSDictionary *)dictionary {
    NSLog(@"GBAnalytics %@: %@, %@", type, event, dictionary);
}

#pragma mark - Util

+(NSString *)_networkNameForNetwork:(GBAnalyticsNetwork)network {
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
    }
}

+(NSString *)_formatEventNameForFacebook:(NSString *)eventName {
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

-(id)initWithRoute:(NSString *)route {
    if (self = [super init]) {
        self.route = route;
    }
    
    return self;
}

#pragma mark - API

-(void)routeToNetworks:(GBAnalyticsNetwork)network, ... NS_REQUIRES_NIL_TERMINATION {
    va_list args;
    GBAnalyticsNetwork aNetwork;
    NSMutableArray *networks = [NSMutableArray new];

    [networks addObject:@(network)];
    va_start(args, network);
    while ((aNetwork = va_arg(args, GBAnalyticsNetwork))) {
        [networks addObject:@(aNetwork)];
    }
    va_end(args);

    self.eventRoutes = networks;
}

-(void)trackEvent:(NSString *)event {
    [GBAnalyticsManager _debugLogString:event force:NO];
    
    //Warn if there are no routes associated here
    if (!(self.eventRoutes.count > 0)) [GBAnalyticsManager _debugWarningString:[NSString stringWithFormat:@"There are no networks associated with the route %@, the following event was not sent: %@", self.route, event] force:YES];
    
    //don't send data if building in debug configuration
//    #if !DEBUG
        if (IsValidString(event)) {
            for (NSNumber *number in [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks) {
                GBAnalyticsNetwork network = [number intValue];
                
                //if it's not routing to this network, then skip it
                if (![self.eventRoutes containsObject:@(network)]) {
//                    NSLog(@"skip: %@", [GBAnalyticsManager _networkNameForNetwork:network]);
                    continue;
                }
                
                switch (network) {
                    case GBAnalyticsNetworkGoogleAnalytics: {
                        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:event action:kGBAnalyticsGoogleAnalyticsActionlessEventActionString label:nil value:nil] build]];
                    } break;
                        
                    case GBAnalyticsNetworkFlurry: {
                        [Flurry logEvent:event];
                    } break;
                        
                    case GBAnalyticsNetworkCrashlytics: {
                        //noop, doesn't support event
                    }
                        
                    case GBAnalyticsNetworkTapstream: {
                        [[TSTapstream instance] fireEvent:[TSEvent eventWithName:event oneTimeOnly:NO]];
                    } break;
                        
                    case GBAnalyticsNetworkFacebook: {
                        [FBAppEvents logEvent:[GBAnalyticsManager _formatEventNameForFacebook:event]];
                    }
                        
                    case GBAnalyticsNetworkMixpanel: {
                        NSLog(@"send mixpanel");
                        [[Mixpanel sharedInstance] track:event];
                    }
                }
            }
        }
        else {
            [GBAnalyticsManager _debugErrorString:@"trackEvent: has not been called with a valid non-empty string" force:YES];
        }
//    #endif
}

-(void)trackEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
    [GBAnalyticsManager _debugLogString:event withDictionary:parameters force:NO];
    
    //Warn if there are no routes associated here
    if (!(self.eventRoutes.count > 0)) [GBAnalyticsManager _debugWarningString:[NSString stringWithFormat:@"There are no networks associated with the route %@, the following event was not sent: %@", self.route, event] force:YES];
    
    //don't send data if building in debug configuration
//    #if !DEBUG
        if (IsValidString(event)) {
            //if the dictionary is not a dict or empty, just forward the call to the simple trackEvent: and thereby discard the event nonsense
            if (![parameters isKindOfClass:[NSDictionary class]] || parameters.count == 0) {
                [self trackEvent:event];
                return;
            }
            
            for (NSNumber *number in [GBAnalyticsManager sharedManager].connectedAnalyticsNetworks) {
                GBAnalyticsNetwork network = [number intValue];
                
                if (network == GBAnalyticsNetworkMixpanel) {
                    NSLog(@"mix");
                }
                
                //if it's not routing to this network, then skip it
                if (![self.eventRoutes containsObject:@(network)]) {
//                    NSLog(@"skip: %@", [GBAnalyticsManager _networkNameForNetwork:network]);
                    continue;
                }
                
                NSLog(@"send: %@", [GBAnalyticsManager _networkNameForNetwork:network]);
                
                
                switch (network) {
                    case GBAnalyticsNetworkGoogleAnalytics: {
                        //for each key/value pair in the dict, send a separate event with a corresponding action/label pair
                        for (NSString *key in parameters) {
                            [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:event action:key label:parameters[key] value:nil] build]];
                        }
                    } break;
                        
                    case GBAnalyticsNetworkFlurry: {
                        [Flurry logEvent:event withParameters:parameters];
                    } break;
                        
                    case GBAnalyticsNetworkCrashlytics: {
                        //noop, doesn't support event
                    }
                        
                    case GBAnalyticsNetworkTapstream: {
                        TSEvent *e = [TSEvent eventWithName:event oneTimeOnly:NO];
                        
                        BOOL shouldSend = NO;
                        for (NSString *key in parameters) {
                            id value = parameters[key];
                            
                            if ([value isKindOfClass:NSString.class]) {
                                [e addValue:value forKey:key];
                                shouldSend = YES;
                            }
                            else if ([value isKindOfClass:NSNumber.class]) {
                                if (strcmp([value objCType], @encode(BOOL)) == 0) {
                                    [e addBooleanValue:[value boolValue] forKey:key];
                                    shouldSend = YES;
                                }
                                else if ((strcmp([value objCType], @encode(int)) == 0) ||
                                         (strcmp([value objCType], @encode(long)) == 0)) {
                                    [e addIntegerValue:[value intValue] forKey:key];
                                    shouldSend = YES;
                                }
                                else if ((strcmp([value objCType], @encode(unsigned int)) == 0) ||
                                         (strcmp([value objCType], @encode(unsigned long)) == 0)) {
                                    [e addUnsignedIntegerValue:[value unsignedIntValue] forKey:key];
                                    shouldSend = YES;
                                }
                                else if ((strcmp([value objCType], @encode(float)) == 0) ||
                                         (strcmp([value objCType], @encode(double)) == 0)) {
                                    [e addDoubleValue:[value doubleValue] forKey:key];
                                    shouldSend = YES;
                                }
                            }
                        }
                        
                        if (shouldSend) [[TSTapstream instance] fireEvent:e];
                    } break;
                        
                    case GBAnalyticsNetworkFacebook: {
                        [FBAppEvents logEvent:[GBAnalyticsManager _formatEventNameForFacebook:event] parameters:parameters];
                    }
                        
                    case GBAnalyticsNetworkMixpanel: {
                        NSLog(@"send mixpanel param");
                        [[Mixpanel sharedInstance] track:event properties:parameters];
                    }
                }
            }
        }
        else {
            [GBAnalyticsManager _debugErrorString:@"trackEvent:withParameters: has not been called with a valid non-empty string" force:YES];
        }
//    #endif
}

@end

