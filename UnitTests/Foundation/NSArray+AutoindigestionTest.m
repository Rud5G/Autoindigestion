#import <SenTestingKit/SenTestingKit.h>
#import "NSArray+Autoindigestion.h"


@interface NSArray_AutoindigestionTest : SenTestCase
@end


@implementation NSArray_AutoindigestionTest
{
  NSString *_pattern;
  NSRegularExpression *_regularExpression;
}


- (void)setUp;
{
  _pattern = [NSString stringWithFormat:@"%@_(\\d{4,8})", @"81234567"];
  _regularExpression = [NSRegularExpression regularExpressionWithPattern:_pattern
                                                                 options:0
                                                                   error:nil];
}


- (void)testFilteredFilenamesUsingRegularExpressionForEmptyArray;
{
  NSArray *unfilteredFilenames = @[];
  
  NSArray *filteredFilenames = [unfilteredFilenames filteredFilenamesUsingRegularExpression:_regularExpression];
  
  STAssertEqualObjects(@[], filteredFilenames, nil);
}


- (void)testFilteredFilenamesUsingRegularExpressionForNoMatchingFilenames;
{
  NSArray *unfilteredFilenames = @[@".", @".."];
  
  NSArray *filteredFilenames = [unfilteredFilenames filteredFilenamesUsingRegularExpression:_regularExpression];
  
  STAssertEqualObjects(@[], filteredFilenames, nil);
}


- (void)testFilteredFilenamesUsingRegularExpressionForOneDailyReport;
{
  NSArray *unfilteredFilenames = @[@".", @"..", @"S_D_81234567_20120522.txt.gz"];
  
  NSArray *filteredFilenames = [unfilteredFilenames filteredFilenamesUsingRegularExpression:_regularExpression];
  
  STAssertEqualObjects(@[@"S_D_81234567_20120522.txt.gz"], filteredFilenames, nil);
}


- (void)testFilteredFilenamesUsingRegularExpressionForMultipleDailyReports;
{
  NSArray *unfilteredFilenames = @[@".",
                                   @"..",
                                   @"S_D_81234567_20120523.txt.gz",
                                   @"Unrelated File.txt",
                                   @"S_D_81234567_20120525.txt.gz",
                                   @"S_D_81234567_20120522.txt.gz",
                                   ];
  
  NSArray *filteredFilenames = [unfilteredFilenames filteredFilenamesUsingRegularExpression:_regularExpression];
  
  NSArray *expected = @[@"S_D_81234567_20120522.txt.gz",
                        @"S_D_81234567_20120523.txt.gz",
                        @"S_D_81234567_20120525.txt.gz",
                        ];
  STAssertEqualObjects(expected, filteredFilenames, nil);
}


- (void)testFilteredFilenamesUsingRegularExpressionForOneWeeklyReport;
{
  NSArray *unfilteredFilenames = @[@".", @"..", @"S_W_81234567_20120520.txt.gz"];
  
  NSArray *filteredFilenames = [unfilteredFilenames filteredFilenamesUsingRegularExpression:_regularExpression];
  
  STAssertEqualObjects(@[@"S_W_81234567_20120520.txt.gz"], filteredFilenames, nil);
}


- (void)testFilteredFilenamesUsingRegularExpressionForOneYearlyReport;
{
  NSArray *unfilteredFilenames = @[@".", @"..", @"S_Y_81234567_2012.txt.gz"];
  
  NSArray *filteredFilenames = [unfilteredFilenames filteredFilenamesUsingRegularExpression:_regularExpression];
  
  STAssertEqualObjects(@[@"S_Y_81234567_2012.txt.gz"], filteredFilenames, nil);
}


@end
