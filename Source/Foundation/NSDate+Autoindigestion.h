#import <Foundation/Foundation.h>


@interface NSDate (Autoindigestion)

- (BOOL)isEarlierThanDate:(NSDate *)date;

- (BOOL)isLaterThanDate:(NSDate *)date;

@end
