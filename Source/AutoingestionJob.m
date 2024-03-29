#import "AutoingestionJob.h"

#import "Autoingestion.h"
#import "AutoingestionResponse.h"
#import "Monitor.h"
#import "ReportCategory.h"
#import "ReportDateType.h"
#import "Vendor.h"


@implementation AutoingestionJob
{
  NSString *_description;
}


- (NSString *)description;
{
  return _description;
}


- (instancetype)init;
{
  [NSException raise:@"Not Implemented" format:@"%s", __FUNCTION__];
  return nil;
}


- (instancetype)initWithMonitor:(id <Monitor>)monitor
                 reportCategory:(ReportCategory *)reportCategory
                  andReportDate:(NSDate *)reportDate;
{
  self = [super init];
  if ( ! self) return nil;
  
  _monitor = monitor;
  _reportCategory = reportCategory;
  _reportDate = reportDate;
  
  Vendor *vendor = [_reportCategory vendor];

  _description = [NSString stringWithFormat:@"%@ for %@",
                                            [_reportCategory reportDescriptionWithDate:_reportDate],
                                            [vendor vendorName]];

  NSArray *reportDirPathComponents = [[_reportCategory reportDir] pathComponents];
  NSUInteger dirCount = [reportDirPathComponents count];
  if ([@"/" isEqualToString:reportDirPathComponents[0]]) dirCount -= 1;
  
  NSMutableArray *credentialsFilePathComponents = [[[vendor credentialsFilePath] pathComponents] mutableCopy];
  if ([@"/" isEqualToString:credentialsFilePathComponents[0]]) {
    [credentialsFilePathComponents removeObjectAtIndex:0];
  }
  for (NSUInteger i = 0; i < dirCount; ++i) {
    [credentialsFilePathComponents insertObject:@".." atIndex:0];
  }
  NSString *credentialsFilePath = [NSString pathWithComponents:credentialsFilePathComponents];
  
  Autoingestion *autoingestion = [_reportCategory autoingestion];
  NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setLocale:locale];
  [dateFormatter setDateFormat:@"yyyyMMdd"];
  NSString *argumentDateString = [dateFormatter stringFromDate:_reportDate];
  
  _arguments = @[
      @"--exec",
      @"java",
      @"-classpath",
      [autoingestion classPath],
      [autoingestion className],
      credentialsFilePath,
      [vendor vendorID],
      [_reportCategory reportType],
      [[_reportCategory reportDateType] name],
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
