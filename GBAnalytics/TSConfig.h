#pragma once
#import <Foundation/Foundation.h>

@interface TSConfig : NSObject {
@private
	// Deprecated, hardware-id field
	NSString *hardware;

	// Optional hardware identifiers that can be provided by the caller
	NSString *odin1;
#if TEST_IOS || TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR	
	NSString *udid;
	NSString *idfa;
	NSString *secureUdid;
	NSString *openUdid;
#else
	NSString *serialNumber;
#endif
	
	// Set these to false if you do NOT want to collect this data
	BOOL collectWifiMac;

	// Set these if you want to override the names of the automatic events sent by the sdk
	NSString *installEventName;
	NSString *openEventName;

	// Unset these if you want to disable the sending of the automatic events
	BOOL fireAutomaticInstallEvent;
	BOOL fireAutomaticOpenEvent;
}

@property(nonatomic, retain) NSString *hardware;
@property(nonatomic, retain) NSString *odin1;
#if TEST_IOS || TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR	
@property(nonatomic, retain) NSString *udid;
@property(nonatomic, retain) NSString *idfa;
@property(nonatomic, retain) NSString *secureUdid;
@property(nonatomic, retain) NSString *openUdid;
#else
@property(nonatomic, retain) NSString *serialNumber;
#endif

@property(nonatomic, assign) BOOL collectWifiMac;

@property(nonatomic, retain) NSString *installEventName;
@property(nonatomic, retain) NSString *openEventName;

@property(nonatomic, assign) BOOL fireAutomaticInstallEvent;
@property(nonatomic, assign) BOOL fireAutomaticOpenEvent;

- (id)init;
+ (id)configWithDefaults;

@end