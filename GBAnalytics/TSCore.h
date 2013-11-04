#pragma once
#import <Foundation/Foundation.h>
#import "TSEvent.h"
#import "TSDelegate.h"
#import "TSPlatform.h"
#import "TSCoreListener.h"
#import "TSHit.h"
#import "TSResponse.h"
#import "TSConfig.h"

@interface TSCore : NSObject {
@private
	id<TSDelegate> del;
	id<TSPlatform> platform;
	id<TSCoreListener> listener;
	TSConfig *config;
	NSString *accountName;
	NSMutableString *postData;
	NSMutableSet *firingEvents;
	NSMutableSet *firedEvents;
	NSString *failingEventId;
	int delay;
}

- (id)initWithDelegate:(id<TSDelegate>)delegate platform:(id<TSPlatform>)platform listener:(id<TSCoreListener>)listener accountName:(NSString *)accountName developerSecret:(NSString *)developerSecret config:(TSConfig *)config;
- (void)start;
- (void)fireEvent:(TSEvent *)event;
- (void)fireHit:(TSHit *)hit completion:(void(^)(TSResponse *))completion;
- (int)getDelay;
- (NSMutableString *)postData;

@end