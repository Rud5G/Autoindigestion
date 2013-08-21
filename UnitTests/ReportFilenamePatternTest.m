#import <SenTestingKit/SenTestingKit.h>
#import "ReportFilenamePattern.h"


@interface ReportFilenamePatternTest : SenTestCase
@end


@implementation ReportFilenamePatternTest


- (void)testReportFilenamePatternForDailySalesSummary;
{
  ReportFilenamePattern *reportFilenamePattern = [[ReportFilenamePattern alloc] initWithVendorID:@"81234567"
                                                                                      reportType:kReportTypeSales
                                                                                   reportSubType:kReportSubtypeSummary
                                                                                     andDateType:kDateTypeDaily];
  
  STAssertEqualObjects(@"S_D_81234567_(\\d{8})\\.txt\\.gz", [reportFilenamePattern pattern], nil);
}


- (void)testReportFilenamePatternForWeeklySalesSummary;
{
  ReportFilenamePattern *reportFilenamePattern = [[ReportFilenamePattern alloc] initWithVendorID:@"81234567"
                                                                                      reportType:kReportTypeSales
                                                                                   reportSubType:kReportSubtypeSummary
                                                                                     andDateType:kDateTypeWeekly];
  
  STAssertEqualObjects(@"S_W_81234567_(\\d{8})\\.txt\\.gz", [reportFilenamePattern pattern], nil);
}


- (void)testReportFilenamePatternForYearlySalesSummary;
{
  ReportFilenamePattern *reportFilenamePattern = [[ReportFilenamePattern alloc] initWithVendorID:@"81234567"
                                                                                      reportType:kReportTypeSales
                                                                                   reportSubType:kReportSubtypeSummary
                                                                                     andDateType:KDateTypeYearly];
  
  STAssertEqualObjects(@"S_Y_81234567_(\\d{4})\\.txt\\.gz", [reportFilenamePattern pattern], nil);
}


@end
