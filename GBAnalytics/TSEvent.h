#pragma once
#import <Foundation/Foundation.h>
#import "TSHelpers.h"

@interface TSEvent : NSObject {
@private
	NSTimeInterval firstFiredTime;
	NSString *uid;
	NSString *name;
	NSString *encodedName;
	BOOL oneTimeOnly;
	NSMutableString *postData;
}

@property(nonatomic, STRONG_OR_RETAIN, readonly) NSString *uid;
@property(nonatomic, STRONG_OR_RETAIN, readonly) NSString *name;
@property(nonatomic, STRONG_OR_RETAIN, readonly) NSString *encodedName;
@property(nonatomic, STRONG_OR_RETAIN, readonly) NSString *postData;
@property(nonatomic, assign, readonly) BOOL oneTimeOnly;

+ (id)eventWithName:(NSString *)name oneTimeOnly:(BOOL)oneTimeOnly;
- (void)addValue:(NSString *)value forKey:(NSString *)key;
- (void)addIntegerValue:(int)value forKey:(NSString *)key;
- (void)addUnsignedIntegerValue:(uint)value forKey:(NSString *)key;
- (void)addDoubleValue:(double)value forKey:(NSString *)key;
- (void)addBooleanValue:(BOOL)value forKey:(NSString *)key;

@end