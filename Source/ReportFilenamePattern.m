#import "ReportFilenamePattern.h"


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
    [NSException raise:@"Regular expression error"
                format:@"%@: pattern=/%@/", error, _pattern];
  }
  
  return self;
}


@end
