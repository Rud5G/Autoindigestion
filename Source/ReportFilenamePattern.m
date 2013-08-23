#import "ReportFilenamePattern.h"
#import "NSArray+Autoindigestion.h"


NSString *const kRegularExpressionError = @"Regular Expression Error";


@implementation ReportFilenamePattern


- (id)initWithVendorID:(NSString *)vendorID
            reportType:(NSString *)reportType
         reportSubType:(NSString *)reportSubType
           andDateType:(NSString *)dateType;
{
  self = [super init];
  if ( ! self) return nil;
  
  _vendorID = [vendorID copy];
  _reportType = [reportType copy];
  _reportSubType = [reportSubType copy];
  _dateType = [dateType copy];
  
  int dateStringLength = 8;
  if ([KDateTypeYearly isEqualToString:_dateType]) {
    dateStringLength = 4;
  }
  
  NSString *patternFormat = @"%C_%C_%@_(\\d{%i})\\.txt\\.gz";
  _pattern = [NSString stringWithFormat:patternFormat,
              [_reportSubType characterAtIndex:0], [_dateType characterAtIndex:0],
              _vendorID, dateStringLength];
  
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
