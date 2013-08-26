#import "NSDate+Autoindigestion.h"


@implementation NSDate (Autoindigestion)


- (BOOL)isLessRecentThanDate:(NSDate *)date;
{
  return NSOrderedAscending == [self compare:date];
}


- (BOOL)isMoreRecentThanDate:(NSDate *)date;
{
  return NSOrderedDescending == [self compare:date];
}


@end
