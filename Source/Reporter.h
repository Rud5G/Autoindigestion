#import <Foundation/Foundation.h>


@protocol Reporter <NSObject>

- (void)errorDidOccur:(NSString *)description;

@end
