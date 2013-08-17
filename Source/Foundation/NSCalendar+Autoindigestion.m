#import "NSCalendar+Autoindigestion.h"


@implementation NSCalendar (Autoindigestion)


- (NSDate *)dateFromReportDate:(NSString *)reportDate;
{
  NSString *yearString = [reportDate substringWithRange:NSMakeRange(0, 4)];
  NSString *monthString = [reportDate substringWithRange:NSMakeRange(4, 2)];
  NSString *dayString = [reportDate substringWithRange:NSMakeRange(6, 2)];

  NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
  [dateComponents setYear:[yearString integerValue]];
  [dateComponents setMonth:[monthString integerValue]];
  [dateComponents setDay:[dayString integerValue]];

  return [self dateFromComponents:dateComponents];
}


- (NSDate *)fiveNewYearsAgoForDate:(NSDate *)date;
{
  return nil;
}


- (NSDate *)nextDayForDate:(NSDate *)date;
{
  NSDateComponents *tomorrow = [[NSDateComponents alloc] init];
  [tomorrow setDay:1];
  return [self dateByAddingComponents:tomorrow
                               toDate:date
                              options:0];
}


- (NSDate *)nextWeekForDate:(NSDate *)date;
{
  NSDateComponents *nextWeek = [[NSDateComponents alloc] init];
  [nextWeek setWeek:1];
  return [self dateByAddingComponents:nextWeek
                               toDate:date
                              options:0];
}


- (NSDate *)nextYearForDate:(NSDate *)date;
{
  return nil;
}


- (NSDate *)previousDayForDate:(NSDate *)date;
{
  NSDateComponents *yesterday = [[NSDateComponents alloc] init];
  [yesterday setDay:-1];
  return [self dateByAddingComponents:yesterday
                               toDate:date
                              options:0];
}


- (NSDate *)previousSundayForDate:(NSDate *)date;
{
  NSCalendarUnit yearMonthDayUnits = NSYearCalendarUnit
                                   | NSMonthCalendarUnit
                                   | NSDayCalendarUnit;
  NSDateComponents *dateComponents = [self components:yearMonthDayUnits
                                             fromDate:date];

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
  NSDateComponents *twoWeeksAgo = [[NSDateComponents alloc] init];
  [twoWeeksAgo setDay:-14];
  return [self dateByAddingComponents:twoWeeksAgo
                               toDate:date
                              options:0];
}


- (NSDate *)zeroOutTimeForDate:(NSDate *)date;
{
  NSCalendarUnit yearMonthDayUnits = NSYearCalendarUnit
                                   | NSMonthCalendarUnit
                                   | NSDayCalendarUnit;
  NSDateComponents *dateComponents = [self components:yearMonthDayUnits
                                             fromDate:date];

  return [self dateFromComponents:dateComponents];
}


@end
