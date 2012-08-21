#import "AutoingestionJob.h"

#import "Autoingestion.h"
#import "AutoingestionResponse.h"
#import "Monitor.h"
#import "ReportCategory.h"
#import "Vendor.h"


@implementation AutoingestionJob
{
  NSString *description;
}


@synthesize arguments;
@synthesize monitor;
@synthesize reportCategory;
@synthesize reportDate;
@synthesize response;


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


- (void)run;
{
  response = [self runTask];
  if ([response isSuccess]) {
    [monitor infoWithFormat:@"Downloaded %@: %@", description, [response filename]];
  } else {
    [monitor warningWithFormat:@"%@:\n\t%@", description, response];
  }
}


- (AutoingestionResponse *)runTask
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
  
  return [[AutoingestionResponse alloc] initWithOutput:buffer];
}


@end
