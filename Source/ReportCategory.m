#import "ReportCategory.h"

#import "Autoingestion.h"
#import "AutoingestionJob.h"
#import "Defaults.h"
#import "Group.h"
#import "Monitor.h"
#import "NSArray+Autoindigestion.h"
#import "NSCalendar+Autoindigestion.h"
#import "NSDate+Autoindigestion.h"
#import "ReportFilenamePattern.h"
#import "User.h"
#import "Vendor.h"


NSString *const kDateTypeDaily = @"Daily";
NSString *const kDateTypeWeekly = @"Weekly";
NSString *const KDateTypeYearly = @"Yearly";
NSString *const kReportSubtypeOptIn = @"Opt-In";
NSString *const kReportSubtypeSummary = @"Summary";
NSString *const kReportTypePreOrder = @"Pre-Order";
NSString *const kReportTypeSales = @"Sales";


@implementation ReportCategory


- (NSArray *)autoingestionJobs;
{
  NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  NSCalendar *calendar = [locale objectForKey:NSLocaleCalendar];
  NSDate *today = [calendar zeroOutTimeForDate:[NSDate date]];
  
  NSDate *startingReportDate = nil;
  if ([self isDaily]) {
    startingReportDate = [calendar twoWeeksAgoForDate:today];
  } else if ([self isWeekly]) {
    startingReportDate = [calendar thirteenSundaysAgoForDate:today];
  } else {
    startingReportDate = [calendar fiveNewYearsDaysAgoForDate:today];
  }
  
  NSError *error;
  NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_reportDir
                                                                           error:&error];
  if ( ! filenames) {
    [_monitor warningWithError:error];
    return [NSArray array];
  }

  ReportFilenamePattern *reportFilenamePattern = [[ReportFilenamePattern alloc] initWithVendorID:[_vendor vendorID]
                                                                                      reportType:_reportType
                                                                                   reportSubType:_reportSubtype
                                                                                     andDateType:_dateType];
  NSArray *existingReportDates = [reportFilenamePattern reportDateStringsFromFilenames:filenames];
  if ([existingReportDates count]) {
    NSDate *latestExistingReportDate = [calendar dateFromReportDate:[existingReportDates lastObject]];
    if ([latestExistingReportDate isLaterThanDate:startingReportDate]) {
      if ([self isDaily]) {
        startingReportDate = [calendar nextDayForDate:latestExistingReportDate];
      } else if ([self isWeekly]) {
        startingReportDate = [calendar nextWeekForDate:latestExistingReportDate];
      } else {
        startingReportDate = [calendar nextYearForDate:latestExistingReportDate];
      }
    }
  }


  NSMutableArray *autoingestionJobs = [NSMutableArray array];
  NSDate *reportDate = startingReportDate;
  while ([reportDate isEarlierThanDate:today]) {
    AutoingestionJob *autoingestionJob = [[AutoingestionJob alloc] initWithMonitor:_monitor
                                                                    reportCategory:self
                                                                     andReportDate:reportDate];
    [autoingestionJobs addObject:autoingestionJob];

    if ([self isDaily]) {
      reportDate = [calendar nextDayForDate:reportDate];
    } else if ([self isWeekly]) {
      reportDate = [calendar nextWeekForDate:reportDate];
    } else {
      reportDate = [calendar nextYearForDate:reportDate];
    }
  }

  return autoingestionJobs;
}


- (id)initWithMonitor:(id <Monitor>)theMonitor
             defaults:(Defaults *)theDefaults
        autoingestion:(Autoingestion *)theAutoingestion
               vendor:(Vendor *)theVendor
           reportType:(NSString *)theReportType
             dateType:(NSString *)theDateType
     andReportSubtype:(NSString *)theReportSubtype;
{
  self = [super init];
  if ( ! self) return nil;

  _autoingestion = theAutoingestion;
  _dateType = theDateType;
  _defaults = theDefaults;
  _monitor = theMonitor;
  _reportSubtype = theReportSubtype;
  _reportType = theReportType;
  _vendor = theVendor;

  _fileMode = [_defaults fileMode];
  _group = [_vendor group];
  _owner = [_vendor owner];

  if (   [kReportTypeSales isEqualToString:_reportType]
      && [kReportSubtypeOptIn isEqualToString:_reportSubtype])
  {
    _reportDir = [[_vendor reportDir] stringByAppendingPathComponent:_reportSubtype];
  } else {
    NSString *reportTypeDir = [[_vendor reportDir] stringByAppendingPathComponent:_reportType];
    _reportDir = [reportTypeDir stringByAppendingPathComponent:_dateType];
  }

  return self;
}


- (BOOL)isDaily;
{
  return [kDateTypeDaily isEqualToString:_dateType];
}


- (BOOL)isWeekly;
{
  return [kDateTypeWeekly isEqualToString:_dateType];
}


- (BOOL)isYearly;
{
  return [KDateTypeYearly isEqualToString:_dateType];
}


- (void)prepare;
{
  if ( ! [[NSFileManager defaultManager] fileExistsAtPath:_reportDir]) {
    NSDictionary *attributes = @{
        NSFileOwnerAccountID : [_owner ID],
        NSFileGroupOwnerAccountID : [_group ID],
        NSFilePosixPermissions : _fileMode,
    };
    NSError *error;
    BOOL created = [[NSFileManager defaultManager] createDirectoryAtPath:_reportDir
                                             withIntermediateDirectories:YES
                                                              attributes:attributes
                                                                   error:&error];
    if ( ! created) {
      [_monitor exitOnFailureWithError:error];
    }
  }
}


@end
