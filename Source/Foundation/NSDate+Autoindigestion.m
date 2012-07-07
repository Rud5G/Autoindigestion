#import "NSDate+Autoindigestion.h"


@implementation NSDate (Autoindigestion)


- (BOOL)isEarlierThanDate:(NSDate *)date;
{
  return NSOrderedAscending == [self compare:date];
}


- (BOOL)isLaterThanDate:(NSDate *)date;
{
  return NSOrderedDescending == [self compare:date];
}


@end
