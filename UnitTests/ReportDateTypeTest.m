#import <SenTestingKit/SenTestingKit.h>
#import "ReportDateType.h"


@interface ReportDateTypeTest : SenTestCase
@end


@implementation ReportDateTypeTest


- (void)testReportDateTypeSingletons
{
  STAssertNotNil([ReportDateType daily], nil);
  STAssertEqualObjects(@"Daily", [[ReportDateType daily] name], nil);
  
  STAssertNotNil([ReportDateType weekly], nil);
  STAssertEqualObjects(@"Weekly", [[ReportDateType weekly] name], nil);
  
  STAssertNotNil([ReportDateType yearly], nil);
  STAssertEqualObjects(@"Yearly", [[ReportDateType yearly] name], nil);
}


@end
