#import <Foundation/Foundation.h>

@protocol MMEUniqueIdentifer <NSObject>

- (NSString *)rollingInstanceIdentifer;

@end

@interface MMEUniqueIdentifier : NSObject <MMEUniqueIdentifer>

- (instancetype)init __attribute__((unavailable("This method is not available")));
- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval;

- (NSString *)rollingInstanceIdentifer;

@end
