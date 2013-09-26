#import <SenTestingKit/SenTestingKit.h>
#import "ReportCategory.h"


@interface ReportCategoryTest : SenTestCase
@end


@implementation ReportCategoryTest
{
  NSDate *_date;
  ReportCategory *_dailyReportCategory;
  ReportCategory *_weeklyReportCategory;
  ReportCategory *_yearlyReportCategory;
}


- (void)setUp;
{
  _date = [NSDate dateWithNaturalLanguageString:@"5/22/2012 08:30:12"];
  _dailyReportCategory = [[ReportCategory alloc] initWithMonitor:nil
                                                        defaults:nil
                                                   autoingestion:nil
                                                          vendor:nil
                                                      reportType:kReportTypeSales
                                                   reportSubtype:kReportSubtypeSummary
                                                        dateType:kDateTypeDaily
                                                         andDate:_date];
  _weeklyReportCategory = [[ReportCategory alloc] initWithMonitor:nil
                                                         defaults:nil
                                                    autoingestion:nil
                                                           vendor:nil
                                                       reportType:kReportTypeSales
                                                    reportSubtype:kReportSubtypeSummary
                                                         dateType:kDateTypeWeekly
                                                          andDate:_date];
  _yearlyReportCategory = [[ReportCategory alloc] initWithMonitor:nil
                                                         defaults:nil
                                                    autoingestion:nil
                                                           vendor:nil
                                                       reportType:kReportTypeSales
                                                    reportSubtype:kReportSubtypeSummary
                                                         dateType:KDateTypeYearly
                                                          andDate:_date];
}


- (void)testMissingReportDatesForDailyReportsWithNoDownloadedReports;
{
  NSArray *missingReportDates = [_dailyReportCategory missingReportDates:@[]];

  STAssertEquals((NSUInteger) 14, [missingReportDates count], nil);
  NSDate *expectedFirstDate = [NSDate dateWithNaturalLanguageString:@"5/8/2012 00:00:00"];
  STAssertEqualObjects(expectedFirstDate, [missingReportDates objectAtIndex:0], nil);
  NSDate *expectedLastDate = [NSDate dateWithNaturalLanguageString:@"5/21/2012 00:00:00"];
  STAssertEqualObjects(expectedLastDate, [missingReportDates lastObject], nil);
}


- (void)testMissingReportDatesForWeeklyReportsWithNoDownloadedReports;
{
  NSArray *missingReportDates = [_weeklyReportCategory missingReportDates:@[]];
  STAssertEquals((NSUInteger) 13, [missingReportDates count], nil);
  NSDate *expectedFirstDate = [NSDate dateWithNaturalLanguageString:@"2/26/2012 00:00:00"];
  STAssertEqualObjects(expectedFirstDate, [missingReportDates objectAtIndex:0], nil);
  NSDate *expectedLastDate = [NSDate dateWithNaturalLanguageString:@"5/20/2012 00:00:00"];
  STAssertEqualObjects(expectedLastDate, [missingReportDates lastObject], nil);
}


- (void)testMissingReportDatesForYearlyReportsWithNoDownloadedReports;
{
  NSArray *missingReportDates = [_yearlyReportCategory missingReportDates:@[]];
  STAssertEquals((NSUInteger) 4, [missingReportDates count], nil);
  NSDate *expectedFirstDate = [NSDate dateWithNaturalLanguageString:@"1/1/2008 00:00:00"];
  STAssertEqualObjects(expectedFirstDate, [missingReportDates objectAtIndex:0], nil);
  NSDate *expectedLastDate = [NSDate dateWithNaturalLanguageString:@"1/1/2011 00:00:00"];
  STAssertEqualObjects(expectedLastDate, [missingReportDates lastObject], nil);
}


@end
