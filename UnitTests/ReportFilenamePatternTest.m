#import <SenTestingKit/SenTestingKit.h>
#import "ReportCategory.h"
#import "ReportDateType.h"
#import "ReportFilenamePattern.h"


@interface ReportFilenamePatternTest : SenTestCase
@end


@implementation ReportFilenamePatternTest
{
  ReportFilenamePattern *dailyReportFilenamePattern;
  ReportFilenamePattern *weeklyReportFilenamePattern;
  ReportFilenamePattern *yearlyReportFilenamePattern;
}


- (void)setUp;
{
  dailyReportFilenamePattern = [[ReportFilenamePattern alloc] initWithVendorID:@"81234567"
                                                                    reportType:kReportTypeSales
                                                                reportDateType:[ReportDateType daily]
                                                              andReportSubType:kReportSubtypeSummary];
  weeklyReportFilenamePattern = [[ReportFilenamePattern alloc] initWithVendorID:@"81234567"
                                                                     reportType:kReportTypeSales
                                                                 reportDateType:[ReportDateType weekly]
                                                               andReportSubType:kReportSubtypeSummary];
  yearlyReportFilenamePattern = [[ReportFilenamePattern alloc] initWithVendorID:@"81234567"
                                                                     reportType:kReportTypeSales
                                                                 reportDateType:[ReportDateType yearly]
                                                               andReportSubType:kReportSubtypeSummary];
}


- (void)testReportFilenamesFromFilenamesForEmptyArray;
{
  NSArray *filenames = @[];
  
  NSArray *reportFilenames = [dailyReportFilenamePattern reportFilenamesFromFilenames:filenames];
  
  STAssertEqualObjects(@[], reportFilenames, nil);
}


- (void)testReportFilenamesFromFilenamesForArrayWithoutReportFilenames;
{
  NSArray *filenames = @[@".", @"..", @"README", @"S_D_123.txt"];
  
  NSArray *reportFilenames = [dailyReportFilenamePattern reportFilenamesFromFilenames:filenames];
  
  STAssertEqualObjects(@[], reportFilenames, nil);
}


#pragma mark --- Daily ----------


- (void)testPatternForDailySalesSummary;
{
  STAssertEqualObjects(@"S_D_81234567_(\\d{8})\\.txt\\.gz", [dailyReportFilenamePattern pattern], nil);
}


- (void)testDailyReportFilenamesFromFilenamesForArrayWithOne;
{
  NSArray *filenames = @[
                         @".",
                         @"..",
                         @"README",
                         @"S_D_81234567_20120522.txt.gz",
                         ];
  
  
  NSArray *reportFilenames = [dailyReportFilenamePattern reportFilenamesFromFilenames:filenames];
  
  STAssertEqualObjects(@[@"S_D_81234567_20120522.txt.gz"], reportFilenames, nil);
}


- (void)testDailyReportFilenamesFromFilenamesForArrayWithSeveral;
{
  NSArray *filenames = @[
                         @"S_D_81234567_20120522.txt.gz",
                         @"S_D_81234567_20120523.txt.gz",
                         @"S_D_81234567_20120521.txt.gz",
                         ];
  
  
  NSArray *reportFilenames = [dailyReportFilenamePattern reportFilenamesFromFilenames:filenames];
  
  NSArray *expected = @[
                        @"S_D_81234567_20120521.txt.gz",
                        @"S_D_81234567_20120522.txt.gz",
                        @"S_D_81234567_20120523.txt.gz",
                        ];
  STAssertEqualObjects(expected, reportFilenames, nil);
}


- (void)testDailyReportFilenamesFromFilenamesForArrayWithWrongTypes;
{
  NSArray *filenames = @[
                         @".",
                         @"..",
                         @"README",
                         @"S_D_81234567_20120522.txt.gz",
                         @"S_W_81234567_20120520.txt.gz",
                         @"S_Y_81234567_2012.txt.gz",
                         ];
  
  NSArray *reportFilenames = [dailyReportFilenamePattern reportFilenamesFromFilenames:filenames];
  
  STAssertEqualObjects(@[@"S_D_81234567_20120522.txt.gz"], reportFilenames, nil);
}


- (void)testDailyReportDateStringsFromFilenamesForArrayWithSeveral;
{
  NSArray *filenames = @[
                         @"S_D_81234567_20120522.txt.gz",
                         @"S_D_81234567_20120523.txt.gz",
                         @"S_D_81234567_20120521.txt.gz",
                         ];
  
  
  NSArray *reportFilenames = [dailyReportFilenamePattern reportDateStringsFromFilenames:filenames];
  
  NSArray *expected = @[
                        @"20120521",
                        @"20120522",
                        @"20120523",
                        ];
  STAssertEqualObjects(expected, reportFilenames, nil);
}


#pragma mark --- Monthly ----------


- (void)testPatternForWeeklySalesSummary;
{
  STAssertEqualObjects(@"S_W_81234567_(\\d{8})\\.txt\\.gz", [weeklyReportFilenamePattern pattern], nil);
}


- (void)testWeeklyReportFilenamesFromFilenamesForArrayWithOne;
{
  NSArray *filenames = @[@".",
                         @"..",
                         @"README",
                         @"S_W_81234567_20120522.txt.gz",
                         ];
  
  
  NSArray *reportFilenames = [weeklyReportFilenamePattern reportFilenamesFromFilenames:filenames];
  
  STAssertEqualObjects(@[@"S_W_81234567_20120522.txt.gz"], reportFilenames, nil);
}


- (void)testWeeklyReportFilenamesFromFilenamesForArrayWithSeveral;
{
  NSArray *filenames = @[
                         @"S_W_81234567_20120520.txt.gz",
                         @"S_W_81234567_20120527.txt.gz",
                         @"S_W_81234567_20120513.txt.gz",
                         ];
  
  
  NSArray *reportFilenames = [weeklyReportFilenamePattern reportFilenamesFromFilenames:filenames];
  
  NSArray *expected = @[
                        @"S_W_81234567_20120513.txt.gz",
                        @"S_W_81234567_20120520.txt.gz",
                        @"S_W_81234567_20120527.txt.gz",
                        ];
  STAssertEqualObjects(expected, reportFilenames, nil);
}


- (void)testWeeklyReportFilenamesFromFilenamesForArrayWithWrongTypes;
{
  NSArray *filenames = @[
                         @".",
                         @"..",
                         @"README",
                         @"S_D_81234567_20120522.txt.gz",
                         @"S_W_81234567_20120520.txt.gz",
                         @"S_Y_81234567_2012.txt.gz",
                         ];
  
  NSArray *reportFilenames = [weeklyReportFilenamePattern reportFilenamesFromFilenames:filenames];
  
  STAssertEqualObjects(@[@"S_W_81234567_20120520.txt.gz"], reportFilenames, nil);
}


- (void)testWeeklyReportDateStringsFromFilenamesForArrayWithWrongTypes;
{
  NSArray *filenames = @[
                         @".",
                         @"..",
                         @"README",
                         @"S_D_81234567_20120522.txt.gz",
                         @"S_W_81234567_20120520.txt.gz",
                         @"S_Y_81234567_2012.txt.gz",
                         ];
  
  NSArray *reportFilenames = [weeklyReportFilenamePattern reportDateStringsFromFilenames:filenames];
  
  STAssertEqualObjects(@[@"20120520"], reportFilenames, nil);
}


#pragma mark --- Yearly ----------


- (void)testPatternForYearlySalesSummary;
{
  STAssertEqualObjects(@"S_Y_81234567_(\\d{4})\\.txt\\.gz", [yearlyReportFilenamePattern pattern], nil);
}


- (void)testYearlyReportFilenamesFromFilenamesForArrayWithOne;
{
  NSArray *filenames = @[@".",
                         @"..",
                         @"README",
                         @"S_Y_81234567_2012.txt.gz",
                         ];
  
  
  NSArray *reportFilenames = [yearlyReportFilenamePattern reportFilenamesFromFilenames:filenames];
  
  STAssertEqualObjects(@[@"S_Y_81234567_2012.txt.gz"], reportFilenames, nil);
}


- (void)testYearlyReportFilenamesFromFilenamesForArrayWithSeveral;
{
  NSArray *filenames = @[
                         @"S_Y_81234567_2011.txt.gz",
                         @"S_Y_81234567_2012.txt.gz",
                         @"S_Y_81234567_2010.txt.gz",
                         ];
  
  
  NSArray *reportFilenames = [yearlyReportFilenamePattern reportFilenamesFromFilenames:filenames];
  
  NSArray *expected = @[
                        @"S_Y_81234567_2010.txt.gz",
                        @"S_Y_81234567_2011.txt.gz",
                        @"S_Y_81234567_2012.txt.gz",
                        ];
  STAssertEqualObjects(expected, reportFilenames, nil);
}


- (void)testYearlyReportFilenamesFromFilenamesForArrayWithWrongTypes;
{
  NSArray *filenames = @[
                         @".",
                         @"..",
                         @"README",
                         @"S_D_81234567_20120522.txt.gz",
                         @"S_W_81234567_20120520.txt.gz",
                         @"S_Y_81234567_2012.txt.gz",
                         ];
  
  NSArray *reportFilenames = [yearlyReportFilenamePattern reportFilenamesFromFilenames:filenames];
  
  STAssertEqualObjects(@[@"S_Y_81234567_2012.txt.gz"], reportFilenames, nil);
}


- (void)testYearlyReportDateStringsFromFilenamesForArrayWithOne;
{
  NSArray *filenames = @[@".",
                         @"S_Y_81234567_2011.txt.gz",
                         @"..",
                         @"README",
                         @"S_Y_81234567_2012.txt.gz",
                         ];
  
  
  NSArray *reportFilenames = [yearlyReportFilenamePattern reportDateStringsFromFilenames:filenames];
  
  NSArray *expected = @[@"2011", @"2012"];
  STAssertEqualObjects(expected, reportFilenames, nil);
}


@end
