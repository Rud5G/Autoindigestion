#import "NSCalendar+Autoindigestion.h"


static NSCalendar *posixCalendar;
static dispatch_once_t posixCalendarOnce;


@implementation NSCalendar (Autoindigestion)


- (NSDate *)dateFromReportDateString:(NSString *)reportDateString;
{
  NSParameterAssert([reportDateString length] >= 4);

  NSUInteger length = [reportDateString length];
  NSString *yearString = [reportDateString substringWithRange:NSMakeRange(0, 4)];
  NSString *monthString = length >= 6
                        ? [reportDateString substringWithRange:NSMakeRange(4, 2)]
                        : @"01";
  NSString *dayString = length >= 8
                      ? [reportDateString substringWithRange:NSMakeRange(6, 2)]
                      : @"01";

  NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
  [dateComponents setYear:[yearString integerValue]];
  [dateComponents setMonth:[monthString integerValue]];
  [dateComponents setDay:[dayString integerValue]];

  return [self dateFromComponents:dateComponents];
}


- (NSDate *)fiveNewYearsDaysAgoForDate:(NSDate *)date;
{
  NSDate *previousNewYearsDay = [self previousNewYearsDayForDate:date];
  NSDateComponents *fourYearsAgo = [[NSDateComponents alloc] init];
  [fourYearsAgo setYear:-4];
  return [self dateByAddingComponents:fourYearsAgo
                               toDate:previousNewYearsDay
                              options:0];
}


- (NSDate *)nextDayForDate:(NSDate *)date;
{
  NSDateComponents *tomorrow = [[NSDateComponents alloc] init];
  [tomorrow setDay:1];
  return [self dateByAddingComponents:tomorrow
                               toDate:[self zeroOutTimeForDate:date]
                              options:0];
}


- (NSDate *)nextWeekForDate:(NSDate *)date;
{
  NSDateComponents *nextWeek = [[NSDateComponents alloc] init];
  [nextWeek setWeek:1];
  return [self dateByAddingComponents:nextWeek
                               toDate:[self zeroOutTimeForDate:date]
                              options:0];
}


- (NSDate *)nextYearForDate:(NSDate *)date;
{
  NSDateComponents *nextYear = [[NSDateComponents alloc] init];
  [nextYear setYear:1];
  return [self dateByAddingComponents:nextYear
                               toDate:[self zeroOutTimeForDate:date]
                              options:0];
}


+ (NSCalendar *)POSIXCalendar;
{
  dispatch_once(&posixCalendarOnce, ^{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    posixCalendar = [locale objectForKey:NSLocaleCalendar];
  });

  return posixCalendar;
}


- (NSDate *)previousDayForDate:(NSDate *)date;
{
  NSDateComponents *yesterday = [[NSDateComponents alloc] init];
  [yesterday setDay:-1];
  return [self dateByAddingComponents:yesterday
                               toDate:[self zeroOutTimeForDate:date]
                              options:0];
}


- (NSDate *)previousNewYearsDayForDate:(NSDate *)date;
{
  NSDateComponents *dateComponents = [self yearMonthDayForDate:date];
  [dateComponents setMonth:1];
  [dateComponents setDay:1];
  return [self dateFromComponents:dateComponents];
}


- (NSDate *)previousSundayForDate:(NSDate *)date;
{
  NSDateComponents *dateComponents = [self yearMonthDayForDate:date];
  NSRange range = [self rangeOfUnit:NSDayCalendarUnit
                             inUnit:NSWeekCalendarUnit
                            forDate:date];
  [dateComponents setDay:range.location];
  return [self dateFromComponents:dateComponents];
}


- (NSDate *)thirteenSundaysAgoForDate:(NSDate *)date;
{
  NSDate *lastSunday = [self previousSundayForDate:date];

  NSDateComponents *twelveWeeksAgo = [[NSDateComponents alloc] init];
  [twelveWeeksAgo setWeek:-12];

  return [self dateByAddingComponents:twelveWeeksAgo
                               toDate:lastSunday
                              options:0];
}


- (NSDate *)twoWeeksAgoForDate:(NSDate *)date;
{
  NSDateComponents *dateComponents = [self yearMonthDayForDate:date];
  [dateComponents setDay:[dateComponents day] - 14];
  return [self dateFromComponents:dateComponents];
}


- (NSDateComponents *)yearMonthDayForDate:(NSDate *)date;
{
  NSCalendarUnit yearMonthDayUnits = NSYearCalendarUnit
                                   | NSMonthCalendarUnit
                                   | NSDayCalendarUnit;
  return [self components:yearMonthDayUnits fromDate:date];
}


- (NSDate *)zeroOutTimeForDate:(NSDate *)date;
{
  return [self dateFromComponents:[self yearMonthDayForDate:date]];
}


@end
