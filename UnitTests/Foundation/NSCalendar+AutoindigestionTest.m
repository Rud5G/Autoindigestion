#import <SenTestingKit/SenTestingKit.h>
#import "NSCalendar+Autoindigestion.h"


@interface NSCalendar_AutoindigestionTest : SenTestCase
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


- (void)testDateFromReportDate;
{
  NSString *reportDate = @"20120522";
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"5/22/2012 00:00:00"
                                                    locale:_locale];
  
  NSDate *date = [_calendar dateFromReportDate:reportDate];
  
  STAssertEqualObjects(expected, date, nil);
}


- (void)testFiveNewYearsAgoForDate;
{
  NSDate *today = [NSDate dateWithNaturalLanguageString:@"5/22/2012 08:30:12"
                                                 locale:_locale];
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"1/1/2008 00:00:00"
                                                    locale:_locale];
  
  NSDate *fiveNewYearsAgo = [_calendar fiveNewYearsDaysAgoForDate:today];
  
  STAssertEqualObjects(expected, fiveNewYearsAgo, nil);
}


- (void)testNextDayForDate;
{
  NSDate *today = [NSDate dateWithNaturalLanguageString:@"5/22/2012 08:30:12"
                                                 locale:_locale];
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"5/23/2012 08:30:12"
                                                    locale:_locale];
  
  NSDate *nextDay = [_calendar nextDayForDate:today];
  
  STAssertEqualObjects(expected, nextDay, nil);
}


- (void)testNextWeekForDate;
{
  NSDate *today = [NSDate dateWithNaturalLanguageString:@"5/22/2012 08:30:12"
                                                 locale:_locale];
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"5/29/2012 08:30:12"
                                                    locale:_locale];
  
  NSDate *nextWeek = [_calendar nextWeekForDate:today];
  
  STAssertEqualObjects(expected, nextWeek, nil);
}


- (void)testNextYearForDate;
{
  NSDate *today = [NSDate dateWithNaturalLanguageString:@"5/22/2012 08:30:12"
                                                 locale:_locale];
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"5/22/2013 08:30:12"
                                                    locale:_locale];
  
  NSDate *nextYear = [_calendar nextYearForDate:today];
  
  STAssertEqualObjects(expected, nextYear, nil);
}


- (void)testPreviousDayForDate;
{
  NSDate *today = [NSDate dateWithNaturalLanguageString:@"5/22/2012 08:30:12"
                                                 locale:_locale];
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"5/21/2012 08:30:12"
                                                    locale:_locale];
  
  NSDate *previousDay = [_calendar previousDayForDate:today];
  
  STAssertEqualObjects(expected, previousDay, nil);
}


- (void)testPreviousNewYearsDayForDate;
{
  NSDate *today = [NSDate dateWithNaturalLanguageString:@"5/22/2012 08:30:12"
                                                 locale:_locale];
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"1/1/2012 00:00:00"
                                                    locale:_locale];
  
  NSDate *previousNewYearsDay = [_calendar previousNewYearsDayForDate:today];
  
  STAssertEqualObjects(expected, previousNewYearsDay, nil);
}


- (void)testPreviousSundayForDate;
{
  NSDate *today = [NSDate dateWithNaturalLanguageString:@"5/22/2012 08:30:12"
                                                 locale:_locale];
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"5/20/2012 00:00:00"
                                                    locale:_locale];
  
  NSDate *previousSunday = [_calendar previousSundayForDate:today];
  
  STAssertEqualObjects(expected, previousSunday, nil);
}


- (void)testThirteenSundaysAgoForDate;
{
  NSDate *today = [NSDate dateWithNaturalLanguageString:@"5/22/2012 08:30:12"
                                                 locale:_locale];
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"2/26/2012 00:00:00"
                                                    locale:_locale];
  
  NSDate *thirteenSundaysAgo = [_calendar thirteenSundaysAgoForDate:today];
  
  STAssertEqualObjects(expected, thirteenSundaysAgo, nil);
}


- (void)testTwoWeeksAgoForDate;
{
  NSDate *today = [NSDate dateWithNaturalLanguageString:@"5/22/2012 08:30:12"
                                                 locale:_locale];
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"5/8/2012 08:30:12"
                                                    locale:_locale];
  
  NSDate *twoWeeksAgo = [_calendar twoWeeksAgoForDate:today];
  
  STAssertEqualObjects(expected, twoWeeksAgo, nil);
}


- (void)testZeroOutTimeForDate;
{
  NSDate *today = [NSDate dateWithNaturalLanguageString:@"5/22/2012 08:30:12"
                                                 locale:_locale];
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"5/22/2012 00:00:00"
                                                    locale:_locale];
  
  NSDate *todayWithZeroTime = [_calendar zeroOutTimeForDate:today];
  
  STAssertEqualObjects(expected, todayWithZeroTime, nil);
}


@end
