#import "AutoingestionJob.h"

#import "Autoingestion.h"
#import "Monitor.h"
#import "NSString+Autoindigestion.h"
#import "ReportCategory.h"
#import "Vendor.h"


NSString *const kAutoingestionResponseNotAvailable =
    @"Auto ingestion is not available for this selection.";
NSString *const kAutoingestionResponseNoReportsAvailable =
    @"There are no reports available to download for this selection.";
NSString *const kAutoingestionResponseTryAgain =
    @"The report you requested is not available at this time.  "
    @"Please try again in a few minutes.";
NSString *const kAutoingestionResponseSuccess =
    @"File Downloaded Successfully";
NSString *const kAutoingestionResponseDailyReportDateOutOfRange =
    @"Daily reports are available only for past 14 days, "
    @"please enter a date within past 14 days.";
NSString *const kAutoingestionResponseWeeklyReportDateOutOfRange =
    @"Weekly reports are available only for past 13 weeks, "
    @"please enter a weekend date within past 13 weeks.";
NSString *const kAutoingestionResponseUnknownHostException =
    @"java.net.UnknownHostException: reportingitc.apple.com";


@implementation AutoingestionJob
{
  NSString *description;
}


@synthesize monitor;
@synthesize reportCategory;
@synthesize reportDate;
@synthesize task;


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
  NSArray *arguments = [NSArray arrayWithObjects:
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
  task = [[NSTask alloc] init];
  [task setArguments:arguments];
  [task setCurrentDirectoryPath:[reportCategory reportDir]];
  [task setLaunchPath:@"/usr/libexec/java_home"];

  return self;
}


- (void)run;
{
  NSString *response = [self runTask];

  if ([response containsString:kAutoingestionResponseSuccess]) {
    [monitor infoWithFormat:@"Downloaded %@", description];
  } else {
    [monitor warningWithFormat:@"%@: %@", description, response];
  }

  if (NSTaskTerminationReasonExit != [task terminationReason]) {
    [monitor warningWithFormat:@"%@: Autoingestion task failed to exit normally",
             description];
  }
  if ([task terminationStatus]) {
    [monitor warningWithFormat:@"%@: Autoingestion task failed with status %i",
             description, [task terminationStatus]];
  }
}


- (NSString *)runTask
{
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
  NSString *response = [[NSString alloc] initWithData:buffer
                                             encoding:NSUTF8StringEncoding];
  return response;
}


@end
