#import "AutoingestionResponse.h"

#import "NSString+Autoindigestion.h"


static NSString *const kAutoingestionResponseNotAvailable =
    @"Auto ingestion is not available for this selection.";
static NSString *const kAutoingestionResponseNoReportsAvailable =
    @"There are no reports available to download for this selection.";
static NSString *const kAutoingestionResponseTryAgainLater =
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
static NSString *const kAutoingestionResponseMonthlyReportDateOutOfRange =
    @"Monthly reports are available only for past 12 months, "
    @"please enter a month within past 12 months.";
static NSString *const kAutoingestionResponseYearlyReportDateOutOfRange =
    @"Please enter a valid year.";
static NSString *const kAutoingestionResponseUnknownHostException =
    @"java.net.UnknownHostException: reportingitc.apple.com";
static NSString *const kAutoingestionResponseSocketException =
    @"java.net.SocketException: Network is down";
static NSString *const kAutoingestionResponseNoRouteToHostException =
    @"java.net.NoRouteToHostException: No route to host";
static NSString *const kAutoingestionResponseConnectException =
    @"java.net.ConnectException: Operation timed out";
static NSString *const kAutoingestionResponseSSLHandshakeException =
    @"javax.net.ssl.SSLHandshakeException: Remote host closed connection during handshake";


static NSString *const kJavaExceptionStackTracePrefix = @"\tat ";
static NSString *const kLineBreak = @"\n";


static NSString *filenameFromResponseText(NSString *responseText);
static enum AutoingestionResponseCode responseCodeFromResponseText(NSString *responseText);
static NSString *responseSummaryFromResponseText(NSString *responseText);


@implementation AutoingestionResponse


- (NSString *)description;
{
  return _summary;
}


- (id)initWithOutput:(NSData *)output;
{
  self = [super init];
  if ( ! self) return nil;
  
  _text = [[NSString alloc] initWithData:output
                                encoding:NSUTF8StringEncoding];

  _code = responseCodeFromResponseText(_text);
  _summary = [responseSummaryFromResponseText(_text) copy];
  _success = (AutoingestionResponseCodeSuccess == _code);

  if (_success) {
    _filename = [filenameFromResponseText(_text) copy];
  }

  if (   AutoingestionResponseCodeUnknownHostException == _code
      || AutoingestionResponseCodeSocketException == _code
      || AutoingestionResponseCodeNoRouteToHostException == _code
      || AutoingestionResponseCodeConnectException == _code)
  {
    _networkUnavailable = YES;
  }
  
  if (AutoingestionResponseCodeTryAgainLater == _code) {
    _tryAgainLater = YES;
  }
  
  return self;
}


@end


static NSString *filenameFromResponseText(NSString *responseText)
{
  NSArray *lines = [responseText componentsSeparatedByString:kLineBreak];
  return lines[0];
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
  } else if ([responseText containsString:kAutoingestionResponseSSLHandshakeException]) {
    return AutoingestionResponseCodeSSLHandshakeException;
  }

  if ([responseText containsString:kAutoingestionResponseNotAvailable]) {
    return AutoingestionResponseCodeNotAvailable;
  } else if ([responseText containsString:kAutoingestionResponseNoReportsAvailable]) {
    return AutoingestionResponseCodeNoReportsAvailable;
  } else if ([responseText containsString:kAutoingestionResponseTryAgainLater]) {
    return AutoingestionResponseCodeTryAgainLater;
  } else if ([responseText containsString:kAutoingestionResponseDailyReportDateOutOfRange]) {
    return AutoingestionResponseCodeDailyReportDateOutOfRange;
  } else if ([responseText containsString:kAutoingestionResponseWeeklyReportDateOutOfRange]) {
    return AutoingestionResponseCodeWeeklyReportDateOutOfRange;
  } else if ([responseText containsString:kAutoingestionResponseMonthlyReportDateOutOfRange]) {
    return AutoingestionResponseCodeMonthlyReportDateOutOfRange;
  } else if ([responseText containsString:kAutoingestionResponseYearlyReportDateOutOfRange]) {
    return AutoingestionResponseCodeYearlyReportDateOutOfRange;
  } else {
    return AutoingestionResponseCodeUnrecognized;
  }
}


static NSString *responseSummaryFromResponseText(NSString *responseText)
{
  NSArray *lines = [responseText componentsSeparatedByString:kLineBreak];
  NSMutableArray *filteredLines = [NSMutableArray array];
  for (NSUInteger i = 0; i < [lines count]; ++i) {
    NSString *line = lines[i];
    if ([line hasPrefix:kJavaExceptionStackTracePrefix]) continue;
    
    line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ( ! [line length]) continue;
    
    if (i) line = [@"\t" stringByAppendingString:line];
    [filteredLines addObject:line];
  }
  return [filteredLines componentsJoinedByString:kLineBreak];
}
