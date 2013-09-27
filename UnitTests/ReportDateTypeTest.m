#import <SenTestingKit/SenTestingKit.h>
#import "ReportDateType.h"


@interface ReportDateTypeTest : SenTestCase
@end


@implementation ReportDateTypeTest
{
  NSDate *_date;
}


- (void)setUp;
{
  _date = [NSDate dateWithNaturalLanguageString:@"5/22/2012 08:30:12"];
}


- (void)testReportDateTypeDaily
{
  STAssertNotNil([ReportDateType daily], nil);
  STAssertEqualObjects(@"D", [[ReportDateType daily] codeLetter], nil);
  STAssertEqualObjects(@"Daily", [[ReportDateType daily] name], nil);

  NSDate *expectedDate = [NSDate dateWithNaturalLanguageString:@"5/23/2012 00:00:00"];
  STAssertEqualObjects(expectedDate, [[ReportDateType daily] nextReportDateAfterDate:_date], nil);

  expectedDate = [NSDate dateWithNaturalLanguageString:@"5/8/2012 00:00:00"];
  STAssertEqualObjects(expectedDate, [[ReportDateType daily] oldestReportDateBeforeDate:_date], nil);
}


- (void)testReportDateTypeWeekly
{
  STAssertNotNil([ReportDateType weekly], nil);
  STAssertEqualObjects(@"W", [[ReportDateType weekly] codeLetter], nil);
  STAssertEqualObjects(@"Weekly", [[ReportDateType weekly] name], nil);

  NSDate *expectedDate = [NSDate dateWithNaturalLanguageString:@"5/29/2012 00:00:00"];
  STAssertEqualObjects(expectedDate, [[ReportDateType weekly] nextReportDateAfterDate:_date], nil);

  expectedDate = [NSDate dateWithNaturalLanguageString:@"2/26/2012 00:00:00"];
  STAssertEqualObjects(expectedDate, [[ReportDateType weekly] oldestReportDateBeforeDate:_date], nil);
}


- (void)testReportDateTypeYearly
{
  STAssertNotNil([ReportDateType yearly], nil);
  STAssertEqualObjects(@"Y", [[ReportDateType yearly] codeLetter], nil);
  STAssertEqualObjects(@"Yearly", [[ReportDateType yearly] name], nil);

  NSDate *expectedDate = [NSDate dateWithNaturalLanguageString:@"5/22/2013 00:00:00"];
  STAssertEqualObjects(expectedDate, [[ReportDateType yearly] nextReportDateAfterDate:_date], nil);

  expectedDate = [NSDate dateWithNaturalLanguageString:@"1/1/2008 00:00:00"];
  STAssertEqualObjects(expectedDate, [[ReportDateType yearly] oldestReportDateBeforeDate:_date], nil);
}


@end
