#import <SenTestingKit/SenTestingKit.h>
#import "ReportCategory.h"
#import "ReportDateType.h"
#import "SenTestCase+Date.h"
#import "Vendor.h"


@interface FakeVendor : NSObject

@property (readonly) Group *group;
@property (readonly) User *owner;
@property (readonly, copy) NSString *reportDir;
@property (readonly, copy) NSString *vendorID;

@end


@interface ReportCategoryTest : SenTestCase
@end


@implementation ReportCategoryTest
{
  NSDate *_date;
  ReportCategory *_dailyReportCategory;
  ReportCategory *_weeklyReportCategory;
  ReportCategory *_monthlyReportCategory;
  ReportCategory *_yearlyReportCategory;
}


- (void)setUp;
{
  _date = [self date:@"5/22/2012 08:30:12"];
  _dailyReportCategory = [[ReportCategory alloc] initWithMonitor:nil
                                                        defaults:nil
                                                   autoingestion:nil
                                                          vendor:nil
                                                      reportType:kReportTypeSales
                                                  reportDateType:[ReportDateType daily]
                                                   reportSubtype:kReportSubtypeSummary
                                                         andDate:_date];
  _weeklyReportCategory = [[ReportCategory alloc] initWithMonitor:nil
                                                         defaults:nil
                                                    autoingestion:nil
                                                           vendor:nil
                                                       reportType:kReportTypeSales
                                                   reportDateType:[ReportDateType weekly]
                                                    reportSubtype:kReportSubtypeSummary
                                                          andDate:_date];
  _monthlyReportCategory = [[ReportCategory alloc] initWithMonitor:nil
                                                          defaults:nil
                                                     autoingestion:nil
                                                            vendor:nil
                                                        reportType:kReportTypeSales
                                                    reportDateType:[ReportDateType monthly]
                                                     reportSubtype:kReportSubtypeSummary
                                                           andDate:_date];
  _yearlyReportCategory = [[ReportCategory alloc] initWithMonitor:nil
                                                         defaults:nil
                                                    autoingestion:nil
                                                           vendor:nil
                                                       reportType:kReportTypeSales
                                                   reportDateType:[ReportDateType yearly]
                                                    reportSubtype:kReportSubtypeSummary
                                                          andDate:_date];
}


- (void)testMissingReportDatesForDailyReportsWithNoDownloadedReports;
{
  NSArray *missingReportDates = [_dailyReportCategory missingReportDates:@[]];

  STAssertEquals((NSUInteger) 14, [missingReportDates count], nil);
  NSDate *expectedFirstDate = [self date:@"5/8/2012 00:00:00"];
  STAssertEqualObjects(expectedFirstDate, [missingReportDates objectAtIndex:0], nil);
  NSDate *expectedLastDate = [self date:@"5/21/2012 00:00:00"];
  STAssertEqualObjects(expectedLastDate, [missingReportDates lastObject], nil);
}


- (void)testMissingReportDatesForWeeklyReportsWithNoDownloadedReports;
{
  NSArray *missingReportDates = [_weeklyReportCategory missingReportDates:@[]];
  STAssertEquals((NSUInteger) 13, [missingReportDates count], nil);
  NSDate *expectedFirstDate = [self date:@"2/26/2012 00:00:00"];
  STAssertEqualObjects(expectedFirstDate, [missingReportDates objectAtIndex:0], nil);
  NSDate *expectedLastDate = [self date:@"5/20/2012 00:00:00"];
  STAssertEqualObjects(expectedLastDate, [missingReportDates lastObject], nil);
}


- (void)testMissingReportDatesForMonthlyReportsWithNoDownloadedReports;
{
  NSArray *missingReportDates = [_monthlyReportCategory missingReportDates:@[]];
  STAssertEquals((NSUInteger) 12, [missingReportDates count], nil);
  NSDate *expectedFirstDate = [self date:@"5/1/2011 00:00:00"];
  STAssertEqualObjects(expectedFirstDate, [missingReportDates objectAtIndex:0], nil);
  NSDate *expectedLastDate = [self date:@"4/1/2012 00:00:00"];
  STAssertEqualObjects(expectedLastDate, [missingReportDates lastObject], nil);
}


- (void)testMissingReportDatesForYearlyReportsWithNoDownloadedReports;
{
  NSArray *missingReportDates = [_yearlyReportCategory missingReportDates:@[]];
  STAssertEquals((NSUInteger) 4, [missingReportDates count], nil);
  NSDate *expectedFirstDate = [self date:@"1/1/2008 00:00:00"];
  STAssertEqualObjects(expectedFirstDate, [missingReportDates objectAtIndex:0], nil);
  NSDate *expectedLastDate = [self date:@"1/1/2011 00:00:00"];
  STAssertEqualObjects(expectedLastDate, [missingReportDates lastObject], nil);
}


- (void)testReportDescriptionWithDateForDailyReports;
{
  STAssertEqualObjects(@"22-May-2012 Daily Sales Summary Report", [_dailyReportCategory reportDescriptionWithDate:_date], nil);
}


- (void)testReportDescriptionWithDateForWeeklyReports;
{
  STAssertEqualObjects(@"22-May-2012 Weekly Sales Summary Report", [_weeklyReportCategory reportDescriptionWithDate:_date], nil);
}


- (void)testReportDescriptionWithDateForMonthlyReports;
{
  STAssertEqualObjects(@"May-2012 Monthly Sales Summary Report", [_monthlyReportCategory reportDescriptionWithDate:_date], nil);
}


- (void)testReportDescriptionWithDateForYearlyReports;
{
  STAssertEqualObjects(@"2012 Yearly Sales Summary Report", [_yearlyReportCategory reportDescriptionWithDate:_date], nil);
}


@end


@implementation FakeVendor


- (instancetype)init;
{
  self = [super init];
  if ( ! self) return nil;

  _reportDir = [@"/reports" copy];
  _vendorID = [@"81234567" copy];

  return self;
}


@end
