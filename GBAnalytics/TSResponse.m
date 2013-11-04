#import "TSResponse.h"
#import "TSHelpers.h"

@implementation TSResponse

@synthesize status = status;
@synthesize message = message;

- (id)initWithStatus:(int)statusVal message:(NSString *)messageVal
{
	if((self = [super init]) != nil)
	{
		status = statusVal;
		message = RETAIN(messageVal);
	}
	return self;
}

- (void)dealloc
{
	RELEASE(message);
	SUPER_DEALLOC;
}

@end