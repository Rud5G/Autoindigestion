#import <Foundation/Foundation.h>


@interface NSDate (Autoindigestion)

- (BOOL)isLessRecentThanDate:(NSDate *)date;

- (BOOL)isMoreRecentThanDate:(NSDate *)date;

@end
