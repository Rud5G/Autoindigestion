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


@implementation AutoingestionJob


@synthesize arugmentDateFormatter;
@synthesize descriptionDateFormatter;
@synthesize monitor;
@synthesize reportCategory;
@synthesize reportDate;
@synthesize task;


- (id)initWithMonitor:(id <Monitor>)theMonitor
       reportCategory:(ReportCategory *)theReportCategory
        andReportDate:(NSDate *)theReportDate;
{
  self = [super init];
  if ( ! self) return nil;

  NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

  arugmentDateFormatter = [[NSDateFormatter alloc] init];
  [arugmentDateFormatter setDateFormat:@"yyyyMMdd"];
  [arugmentDateFormatter setLocale:locale];

  descriptionDateFormatter = [[NSDateFormatter alloc] init];
  [descriptionDateFormatter setDateFormat:@"dd-MMM-yyyy"];
  [descriptionDateFormatter setLocale:locale];

  monitor = theMonitor;
  reportCategory = theReportCategory;
  reportDate = theReportDate;

  Autoingestion *autoingestion = [reportCategory autoingestion];
  Vendor *vendor = [reportCategory vendor];
  NSString *argumentDateString = [arugmentDateFormatter stringFromDate:reportDate];
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
  Vendor *vendor = [reportCategory vendor];
  NSString *reportDateString = [descriptionDateFormatter stringFromDate:reportDate];
  NSString *description = [NSString stringWithFormat:@"%@ %@ %@ Report for %@",
                                    reportDateString,
                                    [reportCategory dateType],
                                    [reportCategory reportType],
                                    [vendor vendorName]];

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


@end
