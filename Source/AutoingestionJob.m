#import "AutoingestionJob.h"

#import "Autoingestion.h"
#import "Monitor.h"
#import "NSString+Autoindigestion.h"
#import "ReportCategory.h"
#import "Vendor.h"


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


@implementation AutoingestionJob
{
  NSString *description;
}


@synthesize arguments;
@synthesize monitor;
@synthesize reportCategory;
@synthesize reportDate;
@synthesize responseCode;


- (NSString *)description;
{
  return description;
}


- (id)initWithMonitor:(id <Monitor>)theMonitor
       reportCategory:(ReportCategory *)theReportCategory
        andReportDate:(NSDate *)theReportDate;
{
  self = [super init];
  if ( ! self) return nil;
  
  monitor = theMonitor;
  reportCategory = theReportCategory;
  reportDate = theReportDate;
  
  Vendor *vendor = [reportCategory vendor];

  NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setLocale:locale];

  [dateFormatter setDateFormat:@"dd-MMM-yyyy"];
  NSString *reportDateString = [dateFormatter stringFromDate:reportDate];
  description = [NSString stringWithFormat:@"%@ %@ %@ Report for %@",
                                           reportDateString,
                                           [reportCategory dateType],
                                           [reportCategory reportType],
                                           [vendor vendorName]];

  Autoingestion *autoingestion = [reportCategory autoingestion];
  [dateFormatter setDateFormat:@"yyyyMMdd"];
  NSString *argumentDateString = [dateFormatter stringFromDate:reportDate];
  arguments = [NSArray arrayWithObjects:
                       @"--exec",
                       @"java",
                       @"-classpath",
                       [autoingestion classPath],
                       [autoingestion className],
                       [vendor username],
                       [vendor password],
                       [vendor vendorID],
                       [reportCategory reportType],
                       [reportCategory dateType],
                       [reportCategory reportSubtype],
                       argumentDateString,
                       nil];

  return self;
}


- (enum AutoingestionResponseCode)responseCodeFromResponse:(NSString *)response;
{
  if ([response containsString:kAutoingestionResponseSuccess]) {
    return AutoingestionResponseCodeSuccess;
  } else if ([response containsString:kAutoingestionResponseUnknownHostException]) {
    // must precede kAutoingestionResponseTryAgain
    return AutoingestionResponseCodeUnknownHostException;
  } else if ([response containsString:kAutoingestionResponseSocketException]) {
    // must precede kAutoingestionResponseTryAgain
    return AutoingestionResponseCodeSocketException;
  } else if ([response containsString:kAutoingestionResponseNoRouteToHostException]) {
    // must precede kAutoingestionResponseTryAgain
    return AutoingestionResponseCodeNoRouteToHostException;
  } else if ([response containsString:kAutoingestionResponseNotAvailable]) {
    return AutoingestionResponseCodeNotAvailable;
  } else if ([response containsString:kAutoingestionResponseNoReportsAvailable]) {
    return AutoingestionResponseCodeNoReportsAvailable;
  } else if ([response containsString:kAutoingestionResponseTryAgain]) {
    return AutoingestionResponseCodeTryAgain;
  } else if ([response containsString:kAutoingestionResponseDailyReportDateOutOfRange]) {
    return AutoingestionResponseCodeDailyReportDateOutOfRange;
  } else if ([response containsString:kAutoingestionResponseWeeklyReportDateOutOfRange]) {
    return AutoingestionResponseCodeWeeklyReportDateOutOfRange;
  } else {
    return AutoingestionResponseCodeUnrecognized;
  }
}


- (void)run;
{
  NSString *response = [self runTask];
  responseCode = [self responseCodeFromResponse:response];

  if (AutoingestionResponseCodeSuccess == responseCode) {
    [monitor infoWithFormat:@"Downloaded %@", description];
  } else {
    [monitor warningWithFormat:@"%@: %@", description, response];
  }
}


- (NSString *)runTask
{
  NSTask *task = [[NSTask alloc] init];
  [task setArguments:arguments];
  [task setCurrentDirectoryPath:[reportCategory reportDir]];
  [task setLaunchPath:@"/usr/libexec/java_home"];

  NSPipe *pipe = [NSPipe pipe];
  NSFileHandle *out = [pipe fileHandleForReading];
  [task setStandardOutput:pipe];
  [task setStandardError:pipe];

  [task launch];

  NSMutableData *buffer = [NSMutableData data];
  while ([task isRunning]) {
    NSData *data = [out availableData];
    [buffer appendData:data];
  }

  if (NSTaskTerminationReasonExit != [task terminationReason]) {
    [monitor warningWithFormat:@"%@: Autoingestion task failed to exit normally",
             description];
  }
  if ([task terminationStatus]) {
    [monitor warningWithFormat:@"%@: Autoingestion task failed with status %i",
             description, [task terminationStatus]];
  }
  
  NSString *response = [[NSString alloc] initWithData:buffer
                                             encoding:NSUTF8StringEncoding];
  return response;
}


@end
