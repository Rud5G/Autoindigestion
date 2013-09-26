#import <SenTestingKit/SenTestingKit.h>
#import "ReportCategory.h"


@interface ReportCategoryTest : SenTestCase
@end


@implementation ReportCategoryTest
{
  ReportCategory *_dailyReportCategory;
  ReportCategory *_weeklyReportCategory;
  ReportCategory *_yearlyReportCategory;
}


- (void)setUp;
{
  _dailyReportCategory = [[ReportCategory alloc] initWithMonitor:nil
                                                        defaults:nil
                                                   autoingestion:nil
                                                          vendor:nil
                                                      reportType:kReportTypeSales
                                                   reportSubtype:kReportSubtypeSummary
                                                     andDateType:kDateTypeDaily];
  _weeklyReportCategory = [[ReportCategory alloc] initWithMonitor:nil
                                                         defaults:nil
                                                    autoingestion:nil
                                                           vendor:nil
                                                       reportType:kReportTypeSales
                                                    reportSubtype:kReportSubtypeSummary
                                                      andDateType:kDateTypeWeekly];
  _yearlyReportCategory = [[ReportCategory alloc] initWithMonitor:nil
                                                         defaults:nil
                                                    autoingestion:nil
                                                           vendor:nil
                                                       reportType:kReportTypeSales
                                                    reportSubtype:kReportSubtypeSummary
                                                      andDateType:KDateTypeYearly];
}


- (void)testMissingReportDatesForDailyReportsWithNoDownloadedReports;
{
  NSArray *missingReportDates = [_dailyReportCategory missingReportDates:@[]];
  STAssertEquals((NSUInteger) 14, [missingReportDates count], nil);
}


- (void)testMissingReportDatesForWeeklyReportsWithNoDownloadedReports;
{
  NSArray *missingReportDates = [_weeklyReportCategory missingReportDates:@[]];
  STAssertEquals((NSUInteger) 13, [missingReportDates count], nil);
}


- (void)testMissingReportDatesForYearlyReportsWithNoDownloadedReports;
{
  NSArray *missingReportDates = [_yearlyReportCategory missingReportDates:@[]];
  STAssertEquals((NSUInteger) 4, [missingReportDates count], nil);
}


@end
