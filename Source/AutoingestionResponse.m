#import "AutoingestionResponse.h"

#import "NSString+Autoindigestion.h"


static NSString *const kAutoingestionResponseNotAvailable =
    @"Auto ingestion is not available for this selection.";
static NSString *const kAutoingestionResponseNoReportsAvailable =
    @"There are no reports available to download for this selection.";
static NSString *const kAutoingestionResponseTryAgain =
    @"The report you requested is not available at this time.  "
    @"Please try again in a few minutes.";
static NSString *const kAutoingestionResponseSuccess =
    @"File Downloaded Successfully";
static NSString *const kAutoingestionResponseDailyReportDateOutOfRange =
    @"Daily reports are available only for past 14 days, "
    @"please enter a date within past 14 days.";
static NSString *const kAutoingestionResponseWeeklyReportDateOutOfRange =
    @"Weekly reports are available only for past 13 weeks, "
    @"please enter a weekend date within past 13 weeks.";
static NSString *const kAutoingestionResponseUnknownHostException =
    @"java.net.UnknownHostException: reportingitc.apple.com";
static NSString *const kAutoingestionResponseSocketException =
    @"java.net.SocketException: Network is down";
static NSString *const kAutoingestionResponseNoRouteToHostException =
    @"java.net.NoRouteToHostException: No route to host";
static NSString *const kAutoingestionResponseConnectException =
    @"java.net.ConnectException: Operation timed out";

static NSString *const kLineBreak = @"\n";


static NSString *filenameFromResponseText(NSString *responseText);
static enum AutoingestionResponseCode responseCodeFromResponseText(NSString *responseText);
static NSString *responseSummaryFromResponseText(NSString *responseText);


@implementation AutoingestionResponse


@synthesize code;
@synthesize filename;
@synthesize networkUnavailable;
@synthesize success;
@synthesize summary;
@synthesize text;


- (NSString *)description;
{
  return summary;
}


- (id)initWithOutput:(NSData *)output;
{
  self = [super init];
  if ( ! self) return nil;
  
  text = [[NSString alloc] initWithData:output
                               encoding:NSUTF8StringEncoding];

  code = responseCodeFromResponseText(text);
  summary = responseSummaryFromResponseText(text);
  success = (AutoingestionResponseCodeSuccess == code);

  if (success) {
    filename = filenameFromResponseText(text);
  }

  if (   AutoingestionResponseCodeUnknownHostException == code
      || AutoingestionResponseCodeSocketException == code
      || AutoingestionResponseCodeNoRouteToHostException == code
      || AutoingestionResponseCodeConnectException == code)
  {
    networkUnavailable = YES;
  }

  return self;
}


@end


static NSString *filenameFromResponseText(NSString *responseText)
{
  NSArray *lines = [responseText componentsSeparatedByString:kLineBreak];
  return [lines objectAtIndex:0];
}


static enum AutoingestionResponseCode responseCodeFromResponseText(NSString *responseText)
{
  if ([responseText containsString:kAutoingestionResponseSuccess]) {
    return AutoingestionResponseCodeSuccess;
  }

  // must check for known exceptions before kAutoingestionResponseTryAgain
  if ([responseText containsString:kAutoingestionResponseUnknownHostException]) {
    return AutoingestionResponseCodeUnknownHostException;
  } else if ([responseText containsString:kAutoingestionResponseSocketException]) {
    return AutoingestionResponseCodeSocketException;
  } else if ([responseText containsString:kAutoingestionResponseNoRouteToHostException]) {
    return AutoingestionResponseCodeNoRouteToHostException;
  } else if ([responseText containsString:kAutoingestionResponseConnectException]) {
    return AutoingestionResponseCodeConnectException;
  }

  if ([responseText containsString:kAutoingestionResponseNotAvailable]) {
    return AutoingestionResponseCodeNotAvailable;
  } else if ([responseText containsString:kAutoingestionResponseNoReportsAvailable]) {
    return AutoingestionResponseCodeNoReportsAvailable;
  } else if ([responseText containsString:kAutoingestionResponseTryAgain]) {
    return AutoingestionResponseCodeTryAgain;
  } else if ([responseText containsString:kAutoingestionResponseDailyReportDateOutOfRange]) {
    return AutoingestionResponseCodeDailyReportDateOutOfRange;
  } else if ([responseText containsString:kAutoingestionResponseWeeklyReportDateOutOfRange]) {
    return AutoingestionResponseCodeWeeklyReportDateOutOfRange;
  } else {
    return AutoingestionResponseCodeUnrecognized;
  }
}


static NSString *responseSummaryFromResponseText(NSString *responseText)
{
  NSArray *lines = [responseText componentsSeparatedByString:kLineBreak];
  NSMutableArray *filteredLines = [NSMutableArray array];
  for (NSUInteger i = 0; i < [lines count]; ++i) {
    NSString *line = [lines objectAtIndex:i];
    if ( ! [line hasPrefix:@"\tat "]) {
      if (i) line = [@"\t" stringByAppendingString:line];
      [filteredLines addObject:line];
    }
  }
  return [filteredLines componentsJoinedByString:kLineBreak];
}
