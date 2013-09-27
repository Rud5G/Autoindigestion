#import "ReportCategory.h"

#import "Autoingestion.h"
#import "AutoingestionJob.h"
#import "Defaults.h"
#import "Group.h"
#import "Monitor.h"
#import "NSCalendar+Autoindigestion.h"
#import "NSDate+Autoindigestion.h"
#import "ReportDateType.h"
#import "ReportFilenamePattern.h"
#import "User.h"
#import "Vendor.h"


NSString *const kReportSubtypeOptIn = @"Opt-In";
NSString *const kReportSubtypeSummary = @"Summary";
NSString *const kReportTypePreOrder = @"Pre-Order";
NSString *const kReportTypeSales = @"Sales";


@implementation ReportCategory


- (NSArray *)autoingestionJobs;
{
  NSError *error;
  NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_reportDir
                                                                           error:&error];
  if ( ! filenames) {
    [_monitor warningWithError:error];
    return [NSArray array];
  }
  
  NSMutableArray *autoingestionJobs = [NSMutableArray array];
  for (NSDate *missingReportDate in [self missingReportDates:filenames]) {
    AutoingestionJob *autoingestionJob = [[AutoingestionJob alloc] initWithMonitor:_monitor
                                                                    reportCategory:self
                                                                     andReportDate:missingReportDate];
    [autoingestionJobs addObject:autoingestionJob];
  }

  return autoingestionJobs;
}


- (id)initWithMonitor:(id<Monitor>)monitor
             defaults:(Defaults *)defaults
        autoingestion:(Autoingestion *)autoingestion
               vendor:(Vendor *)vendor
           reportType:(NSString *)reportType
       reportDateType:(ReportDateType *)reportDateType
        reportSubtype:(NSString *)reportSubtype
              andDate:(NSDate *)date;
{
  self = [super init];
  if ( ! self) return nil;

  _autoingestion = autoingestion;
  _date = date;
  _dateType = [reportDateType name];
  _defaults = defaults;
  _monitor = monitor;
  _reportDateType = reportDateType;
  _reportSubtype = reportSubtype;
  _reportType = reportType;
  _vendor = vendor;

  _fileMode = [_defaults fileMode];
  _group = [_vendor group];
  _owner = [_vendor owner];
  _today = [[NSCalendar posixCalendar] zeroOutTimeForDate:_date];

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
  return [ReportDateType daily] == _reportDateType;
}


- (BOOL)isWeekly;
{
  return [ReportDateType weekly] == _reportDateType;
}


- (BOOL)isValidReportDate:(NSDate *)date;
{
  NSDate *invalidReportDate = _today;
  if ([self isYearly]) {
    invalidReportDate = [[NSCalendar posixCalendar] previousNewYearsDayForDate:_today];
  }
  return [date isLessRecentThanDate:invalidReportDate];
}


- (BOOL)isYearly;
{
  return [ReportDateType yearly] == _reportDateType;
}


- (NSArray *)missingReportDates:(NSArray *)filenames;
{
  NSDate *startingReportDate = [self startingReportDate];
  ReportFilenamePattern *reportFilenamePattern = [[ReportFilenamePattern alloc] initWithVendorID:[_vendor vendorID]
                                                                                      reportType:_reportType
                                                                                  reportDateType:_reportDateType
                                                                                andReportSubType:_reportSubtype];
  NSDate *mostRecentExistingReportDate = [reportFilenamePattern mostRecentReportDateFromFilenames:filenames];
  if (mostRecentExistingReportDate) {
    if ([mostRecentExistingReportDate isMoreRecentThanDate:startingReportDate]) {
      startingReportDate = [self nextReportDateAfterReportDate:mostRecentExistingReportDate];
    }
  }
  
  NSMutableArray *missingReportDates = [NSMutableArray array];
  NSDate *missingReportDate = startingReportDate;
  while ([self isValidReportDate:missingReportDate]) {
    [missingReportDates addObject:missingReportDate];
    missingReportDate = [self nextReportDateAfterReportDate:missingReportDate];
  }
  
  return missingReportDates;
}


- (NSDate *)nextReportDateAfterReportDate:(NSDate *)reportDate;
{
  if ([self isDaily]) {
    return [[NSCalendar posixCalendar] nextDayForDate:reportDate];
  } else if ([self isWeekly]) {
    return [[NSCalendar posixCalendar] nextWeekForDate:reportDate];
  } else {
    return [[NSCalendar posixCalendar] nextYearForDate:reportDate];
  }
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


- (NSDate *)startingReportDate;
{
  if ([self isDaily]) {
    return [[NSCalendar posixCalendar] twoWeeksAgoForDate:_today];
  } else if ([self isWeekly]) {
    return [[NSCalendar posixCalendar] thirteenSundaysAgoForDate:_today];
  } else {
    return [[NSCalendar posixCalendar] fiveNewYearsDaysAgoForDate:_today];
  }
}


@end
