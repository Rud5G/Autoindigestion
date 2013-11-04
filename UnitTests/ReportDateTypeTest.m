#import <SenTestingKit/SenTestingKit.h>
#import "ReportDateType.h"
#import "SenTestCase+Date.h"


@interface ReportDateTypeTest : SenTestCase
@end


@implementation ReportDateTypeTest
{
  NSDate *_date;
}


- (void)setUp;
{
  _date = [self date:@"5/22/2012 08:30:12"];
}


- (void)testReportDateTypeDaily
{
  STAssertNotNil([ReportDateType daily], nil);
  STAssertEqualObjects(@"D", [[ReportDateType daily] codeLetter], nil);
  STAssertEquals(8, [[ReportDateType daily] dateStringLength], nil);
  STAssertEqualObjects(@"Daily", [[ReportDateType daily] name], nil);
  STAssertEqualObjects(@"22-May-2012", [[ReportDateType daily] formattedDateForDate:_date], nil);

  NSDate *expectedDate = [self date:@"5/23/2012 00:00:00"];
  STAssertEqualObjects(expectedDate, [[ReportDateType daily] nextReportDateAfterDate:_date], nil);

  expectedDate = [self date:@"5/8/2012 00:00:00"];
  STAssertEqualObjects(expectedDate, [[ReportDateType daily] oldestReportDateBeforeDate:_date], nil);
}


- (void)testReportDateTypeWeekly
{
  STAssertNotNil([ReportDateType weekly], nil);
  STAssertEqualObjects(@"W", [[ReportDateType weekly] codeLetter], nil);
  STAssertEquals(8, [[ReportDateType weekly] dateStringLength], nil);
  STAssertEqualObjects(@"Weekly", [[ReportDateType weekly] name], nil);
  STAssertEqualObjects(@"22-May-2012", [[ReportDateType weekly] formattedDateForDate:_date], nil);

  NSDate *expectedDate = [self date:@"5/29/2012 00:00:00"];
  STAssertEqualObjects(expectedDate, [[ReportDateType weekly] nextReportDateAfterDate:_date], nil);

  expectedDate = [self date:@"2/26/2012 00:00:00"];
  STAssertEqualObjects(expectedDate, [[ReportDateType weekly] oldestReportDateBeforeDate:_date], nil);
}


- (void)testReportDateTypeMonthly
{
  STAssertNotNil([ReportDateType monthly], nil);
  STAssertEqualObjects(@"M", [[ReportDateType monthly] codeLetter], nil);
  STAssertEquals(6, [[ReportDateType monthly] dateStringLength], nil);
  STAssertEqualObjects(@"Monthly", [[ReportDateType monthly] name], nil);
  STAssertEqualObjects(@"May-2012", [[ReportDateType monthly] formattedDateForDate:_date], nil);

  NSDate *expectedDate = [self date:@"6/22/2012 00:00:00"];
  STAssertEqualObjects(expectedDate, [[ReportDateType monthly] nextReportDateAfterDate:_date], nil);

  expectedDate = [self date:@"5/1/2011 00:00:00"];
  STAssertEqualObjects(expectedDate, [[ReportDateType monthly] oldestReportDateBeforeDate:_date], nil);
}


- (void)testReportDateTypeYearly
{
  STAssertNotNil([ReportDateType yearly], nil);
  STAssertEqualObjects(@"Y", [[ReportDateType yearly] codeLetter], nil);
  STAssertEquals(4, [[ReportDateType yearly] dateStringLength], nil);
  STAssertEqualObjects(@"Yearly", [[ReportDateType yearly] name], nil);
  STAssertEqualObjects(@"2012", [[ReportDateType yearly] formattedDateForDate:_date], nil);

  NSDate *expectedDate = [self date:@"5/22/2013 00:00:00"];
  STAssertEqualObjects(expectedDate, [[ReportDateType yearly] nextReportDateAfterDate:_date], nil);

  expectedDate = [self date:@"1/1/2008 00:00:00"];
  STAssertEqualObjects(expectedDate, [[ReportDateType yearly] oldestReportDateBeforeDate:_date], nil);
}


@end
