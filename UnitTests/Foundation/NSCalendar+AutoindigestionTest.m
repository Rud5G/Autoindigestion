#import <SenTestingKit/SenTestingKit.h>
#import "NSCalendar+Autoindigestion.h"


@interface NSCalendar_AutoindigestionTest : SenTestCase

- (NSDate *)date:(NSString *)expectedDateString;

@end


@implementation NSCalendar_AutoindigestionTest
{
  NSLocale *_locale;
  NSCalendar *_calendar;
}


- (void)setUp;
{
  _locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  _calendar = [_locale objectForKey:NSLocaleCalendar];
}


- (void)testDateFromReportDateStringForDailyString;
{
  NSDate *date = [_calendar dateFromReportDateString:@"20120522"];
  
  STAssertEqualObjects([self date:@"5/22/2012 00:00:00"], date, nil);
}


- (void)testDateFromReportDateStringForYearlyString;
{
  NSDate *date = [_calendar dateFromReportDateString:@"2012"];

  STAssertEqualObjects([self date:@"1/1/2012 00:00:00"], date, nil);
}


- (void)testFiveNewYearsAgoForDate;
{
  NSDate *fiveNewYearsAgo = [_calendar fiveNewYearsDaysAgoForDate:[self date:@"5/22/2012 08:30:12"]];
  
  STAssertEqualObjects([self date:@"1/1/2008 00:00:00"], fiveNewYearsAgo, nil);
}


- (void)testNextDayForDate;
{
  NSDate *nextDay = [_calendar nextDayForDate:[self date:@"5/22/2012 08:30:12"]];
  
  STAssertEqualObjects([self date:@"5/23/2012 00:00:0"], nextDay, nil);
}


- (void)testNextWeekForDate;
{
  NSDate *nextWeek = [_calendar nextWeekForDate:[self date:@"5/22/2012 08:30:12"]];
  
  STAssertEqualObjects([self date:@"5/29/2012 00:00:00"], nextWeek, nil);
}


- (void)testNextMonthForDate;
{
  NSDate *nextMonth = [_calendar nextMonthForDate:[self date:@"5/22/2012 08:30:12"]];

  STAssertEqualObjects([self date:@"6/22/2012 00:00:00"], nextMonth, nil);
}


- (void)testNextYearForDate;
{
  NSDate *nextYear = [_calendar nextYearForDate:[self date:@"5/22/2012 08:30:12"]];
  
  STAssertEqualObjects([self date:@"5/22/2013 00:00:00"], nextYear, nil);
}


- (void)testPreviousDayForDate;
{
  NSDate *previousDay = [_calendar previousDayForDate:[self date:@"5/22/2012 08:30:12"]];
  
  STAssertEqualObjects([self date:@"5/21/2012 00:00:00"], previousDay, nil);
}


- (void)testPreviousFirstOfTheMonthForDate;
{
  NSDate *previousFirstOfTheMonth = [_calendar previousFirstOfTheMonthForDate:[self date:@"5/22/2012 08:30:12"]];

  STAssertEqualObjects([self date:@"5/1/2012 00:00:00"], previousFirstOfTheMonth, nil);
}


- (void)testPreviousNewYearsDayForDate;
{
  NSDate *previousNewYearsDay = [_calendar previousNewYearsDayForDate:[self date:@"5/22/2012 08:30:12"]];
  
  STAssertEqualObjects([self date:@"1/1/2012 00:00:00"], previousNewYearsDay, nil);
}


- (void)testPreviousSundayForDate;
{
  NSDate *previousSunday = [_calendar previousSundayForDate:[self date:@"5/22/2012 08:30:12"]];
  
  STAssertEqualObjects([self date:@"5/20/2012 00:00:00"], previousSunday, nil);
}


- (void)testThirteenSundaysAgoForDate;
{
  NSDate *thirteenSundaysAgo = [_calendar thirteenSundaysAgoForDate:[self date:@"5/22/2012 08:30:12"]];
  
  STAssertEqualObjects([self date:@"2/26/2012 00:00:00"], thirteenSundaysAgo, nil);
}


- (void)testTwelveFirstOfTheMonthsAgoForDate;
{
  NSDate *twelveFirstOfTheMonthsAgo = [_calendar twelveFirstOfTheMonthsAgoForDate:[self date:@"5/22/2012 08:30:12"]];

  STAssertEqualObjects([self date:@"5/1/2011 00:00:00"], twelveFirstOfTheMonthsAgo, nil);
}


- (void)testTwoWeeksAgoForDate;
{
  NSDate *twoWeeksAgo = [_calendar twoWeeksAgoForDate:[self date:@"5/22/2012 08:30:12"]];
  
  STAssertEqualObjects([self date:@"5/8/2012 00:00:00"], twoWeeksAgo, nil);
}


- (void)testZeroOutTimeForDate;
{
  NSDate *todayWithZeroTime = [_calendar zeroOutTimeForDate:[self date:@"5/22/2012 08:30:12"]];
  
  STAssertEqualObjects([self date:@"5/22/2012 00:00:00"], todayWithZeroTime, nil);
}


- (NSDate *)date:(NSString *)expectedDateString;
{
  return [NSDate dateWithNaturalLanguageString:expectedDateString
                                        locale:_locale];
}


@end
