#pragma once
#import <Foundation/Foundation.h>

@interface TSResponse : NSObject {
@private
	int status;
	NSString *message;
}

@property(nonatomic, assign, readonly) int status;
@property(nonatomic, retain, readonly) NSString *message;

- (id)initWithStatus:(int)status message:(NSString *)message;

@end