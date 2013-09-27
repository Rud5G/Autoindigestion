#import <SenTestingKit/SenTestingKit.h>
#import "ReportDateType.h"


@interface ReportDateTypeTest : SenTestCase
@end


@implementation ReportDateTypeTest


- (void)testReportDateTypeDaily
{
  STAssertNotNil([ReportDateType daily], nil);
  STAssertEqualObjects(@"D", [[ReportDateType daily] codeLetter], nil);
  STAssertEqualObjects(@"Daily", [[ReportDateType daily] name], nil);
}


- (void)testReportDateTypeWeekly
{
  STAssertNotNil([ReportDateType weekly], nil);
  STAssertEqualObjects(@"W", [[ReportDateType weekly] codeLetter], nil);
  STAssertEqualObjects(@"Weekly", [[ReportDateType weekly] name], nil);
}


- (void)testReportDateTypeYearly
{
  STAssertNotNil([ReportDateType yearly], nil);
  STAssertEqualObjects(@"Y", [[ReportDateType yearly] codeLetter], nil);
  STAssertEqualObjects(@"Yearly", [[ReportDateType yearly] name], nil);
}


@end
