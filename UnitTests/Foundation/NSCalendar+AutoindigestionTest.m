#import <SenTestingKit/SenTestingKit.h>
#import "NSCalendar+Autoindigestion.h"


@interface NSCalendar_AutoindigestionTest : SenTestCase
@end


@implementation NSCalendar_AutoindigestionTest
{
  NSLocale *_locale;
  NSCalendar *_calendar;
  NSDate *_today;
}

- (void)setUp;
{
  _locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  _calendar = [_locale objectForKey:NSLocaleCalendar];
  _today = [NSDate dateWithNaturalLanguageString:@"5/22/2012 08:30:12"
                                          locale:_locale];
}


- (void)testDateFromReportDate;
{
  NSString *reportDate = @"20120522";
  NSDate *date = [_calendar dateFromReportDate:reportDate];
  
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"5/22/2012 00:00:00"
                                                    locale:_locale];
  STAssertEqualObjects(expected, date, nil);
}


- (void)testFiveNewYearsAgoForDate;
{
  NSDate *fiveNewYearsAgo = [_calendar fiveNewYearsDaysAgoForDate:_today];
  
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"1/1/2008 00:00:00"
                                                    locale:_locale];
  STAssertEqualObjects(expected, fiveNewYearsAgo, nil);
}


- (void)testNextDayForDate;
{
  NSDate *nextDay = [_calendar nextDayForDate:_today];
  
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"5/23/2012 08:30:12"
                                                    locale:_locale];
  STAssertEqualObjects(expected, nextDay, nil);
}


- (void)testNextWeekForDate;
{
  NSDate *nextWeek = [_calendar nextWeekForDate:_today];
  
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"5/29/2012 08:30:12"
                                                    locale:_locale];
  STAssertEqualObjects(expected, nextWeek, nil);
}


- (void)testNextYearForDate;
{
  NSDate *nextYear = [_calendar nextYearForDate:_today];
  
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"5/22/2013 08:30:12"
                                                    locale:_locale];
  STAssertEqualObjects(expected, nextYear, nil);
}


- (void)testPreviousDayForDate;
{
  NSDate *previousDay = [_calendar previousDayForDate:_today];
  
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"5/21/2012 08:30:12"
                                                    locale:_locale];
  STAssertEqualObjects(expected, previousDay, nil);
}


- (void)testPreviousNewYearsDayForDate;
{
  NSDate *previousNewYearsDay = [_calendar previousNewYearsDayForDate:_today];
  
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"1/1/2012 00:00:00"
                                                    locale:_locale];
  STAssertEqualObjects(expected, previousNewYearsDay, nil);
}


- (void)testPreviousSundayForDate;
{
  NSDate *previousSunday = [_calendar previousSundayForDate:_today];
  
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"5/20/2012 00:00:00"
                                                    locale:_locale];
  STAssertEqualObjects(expected, previousSunday, nil);
}


- (void)testThirteenSundaysAgoForDate;
{
  NSDate *thirteenSundaysAgo = [_calendar thirteenSundaysAgoForDate:_today];
  
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"2/26/2012 00:00:00"
                                                    locale:_locale];
  STAssertEqualObjects(expected, thirteenSundaysAgo, nil);
}


- (void)testTwoWeeksAgoForDate;
{
  NSDate *twoWeeksAgo = [_calendar twoWeeksAgoForDate:_today];
  
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"5/8/2012 08:30:12"
                                                    locale:_locale];
  STAssertEqualObjects(expected, twoWeeksAgo, nil);
}


- (void)testZeroOutTimeForDate;
{
  NSDate *todayWithZeroTime = [_calendar zeroOutTimeForDate:_today];
  
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"5/22/2012 00:00:00"
                                                    locale:_locale];
  STAssertEqualObjects(expected, todayWithZeroTime, nil);
}


@end
