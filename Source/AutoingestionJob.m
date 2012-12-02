#import "AutoingestionJob.h"

#import "Autoingestion.h"
#import "AutoingestionResponse.h"
#import "Monitor.h"
#import "ReportCategory.h"
#import "Vendor.h"


@implementation AutoingestionJob
{
  NSString *_description;
}


- (NSString *)description;
{
  return _description;
}


- (id)initWithMonitor:(id <Monitor>)theMonitor
       reportCategory:(ReportCategory *)theReportCategory
        andReportDate:(NSDate *)theReportDate;
{
  self = [super init];
  if ( ! self) return nil;
  
  _monitor = theMonitor;
  _reportCategory = theReportCategory;
  _reportDate = theReportDate;
  
  Vendor *vendor = [_reportCategory vendor];

  NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setLocale:locale];

  [dateFormatter setDateFormat:@"dd-MMM-yyyy"];
  NSString *reportDateString = [dateFormatter stringFromDate:_reportDate];
  _description = [NSString stringWithFormat:@"%@ %@ %@ Report for %@",
                                            reportDateString,
                                            [_reportCategory dateType],
                                            [_reportCategory reportType],
                                            [vendor vendorName]];

  Autoingestion *autoingestion = [_reportCategory autoingestion];
  [dateFormatter setDateFormat:@"yyyyMMdd"];
  NSString *argumentDateString = [dateFormatter stringFromDate:_reportDate];
  _arguments = @[
      @"--exec",
      @"java",
      @"-classpath",
      [autoingestion classPath],
      [autoingestion className],
      [vendor username],
      [vendor password],
      [vendor vendorID],
      [_reportCategory reportType],
      [_reportCategory dateType],
      [_reportCategory reportSubtype],
      argumentDateString,
  ];

  return self;
}


- (void)run;
{
  _response = [self runTask];
  if ([_response isSuccess]) {
    [_monitor infoWithFormat:@"Downloaded %@: %@", _description, [_response filename]];
  } else {
    [_monitor warningWithFormat:@"%@:\n\t%@", _description, _response];
  }
}


- (AutoingestionResponse *)runTask
{
  NSTask *task = [[NSTask alloc] init];
  [task setArguments:_arguments];
  [task setCurrentDirectoryPath:[_reportCategory reportDir]];
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
    [_monitor warningWithFormat:@"%@: Autoingestion task failed to exit normally",
                                _description];
  }
  if ([task terminationStatus]) {
    [_monitor warningWithFormat:@"%@: Autoingestion task failed with status %i",
                                _description, [task terminationStatus]];
  }
  
  return [[AutoingestionResponse alloc] initWithOutput:buffer];
}


@end
