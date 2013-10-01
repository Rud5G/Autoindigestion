#import "ReportFilenamePattern.h"

#import "NSArray+Autoindigestion.h"
#import "NSCalendar+Autoindigestion.h"
#import "ReportDateType.h"


NSString *const kRegularExpressionError = @"Regular Expression Error";


@implementation ReportFilenamePattern


- (instancetype)init;
{
  [NSException raise:@"Not Implemented" format:@"%s", __FUNCTION__];
  return nil;
}


- (instancetype)initWithVendorID:(NSString *)vendorID
                      reportType:(NSString *)reportType
                  reportDateType:(ReportDateType *)reportDateType
                andReportSubType:(NSString *)reportSubType;
{
  self = [super init];
  if ( ! self) return nil;
  
  _vendorID = [vendorID copy];
  _reportType = [reportType copy];
  _reportDateType = reportDateType;
  _reportSubType = [reportSubType copy];

  NSString *patternFormat = @"%C_%@_%@_(\\d{%i})\\.txt\\.gz";
  _pattern = [NSString stringWithFormat:patternFormat,
              [_reportSubType characterAtIndex:0], [_reportDateType codeLetter],
              _vendorID, [_reportDateType dateStringLength]];
  
  NSError *error = nil;
  _regularExpression = [NSRegularExpression regularExpressionWithPattern:_pattern
                                                                 options:0
                                                                   error:&error];
  if ( ! _regularExpression) {
    [NSException raise:kRegularExpressionError
                format:@"Unable to create regular expression, pattern=/%@/, error=%@", _pattern, error];
  }
  
  return self;
}


- (NSDate *)mostRecentReportDateFromFilenames:(NSArray *)filenames;
{
  NSArray *reportDateStrings = [self reportDateStringsFromFilenames:filenames];
  if ([reportDateStrings count]) {
    NSString *mostRecentReportDateString = [reportDateStrings lastObject];
    return [[NSCalendar POSIXCalendar] dateFromReportDateString:mostRecentReportDateString];
  } else {
    return nil;
  }
}


- (NSArray *)reportDateStringsFromFilenames:(NSArray *)filenames;
{
  NSMutableArray *reportDateStrings = [NSMutableArray array];
  NSArray *reportFilenames = [self reportFilenamesFromFilenames:filenames];
  for (NSString *reportFilename in reportFilenames) {
    NSRange range = NSMakeRange(0, [reportFilename length]);
    NSTextCheckingResult *textCheckingResult = [_regularExpression firstMatchInString:reportFilename
                                                                              options:0
                                                                                range:range];
    if (NSNotFound == [textCheckingResult range].location) {
      [NSException raise:kRegularExpressionError
                  format:@"Report filename \"%@\" didn't match pattern /%@/", reportFilename, _pattern];
    }
    if ([textCheckingResult numberOfRanges] < 2) {
      [NSException raise:kRegularExpressionError
                  format:@"Date part not found in report filename \"%@\" using pattern /%@/", reportFilename, _pattern];
    }
    NSString *reportDateString = [reportFilename substringWithRange:[textCheckingResult rangeAtIndex:1]];
    [reportDateStrings addObject:reportDateString];
  }
  [reportDateStrings sortUsingSelector:@selector(compare:)];
  return reportDateStrings;
}


- (NSArray *)reportFilenamesFromFilenames:(NSArray *)filenames;
{
  return [filenames filteredFilenamesUsingRegularExpression:_regularExpression];
}


@end
