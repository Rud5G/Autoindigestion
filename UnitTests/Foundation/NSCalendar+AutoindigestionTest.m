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


- (void)testNextDayForDate;
{
  NSDate *today = [NSDate dateWithNaturalLanguageString:@"5/10/2012 08:30:12"
                                                 locale:_locale];
  NSDate *expected = [NSDate dateWithNaturalLanguageString:@"5/11/2012 08:30:12"
                                                    locale:_locale];
  
  NSDate *nextDay = [_calendar nextDayForDate:today];
  
  STAssertEqualObjects(expected, nextDay, nil);
}


@end
