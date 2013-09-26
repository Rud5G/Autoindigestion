#import "ReportCategory.h"

#import "Autoingestion.h"
#import "AutoingestionJob.h"
#import "Defaults.h"
#import "Group.h"
#import "Monitor.h"
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
        reportSubtype:(NSString *)reportSubtype
          andDateType:(NSString *)dateType;
{
  self = [super init];
  if ( ! self) return nil;

  _autoingestion = autoingestion;
  _dateType = dateType;
  _defaults = defaults;
  _monitor = monitor;
  _reportSubtype = reportSubtype;
  _reportType = reportType;
  _today = [[NSCalendar posixCalendar] zeroOutTimeForDate:[NSDate date]];
  _vendor = vendor;

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


- (BOOL)isValidReportDate:(NSDate *)date;
{
  NSDate *invalidReportDate = _today;
  if ([KDateTypeYearly isEqualToString:_dateType]) {
    invalidReportDate = [[NSCalendar posixCalendar] previousNewYearsDayForDate:_today];
  }
  return [date isLessRecentThanDate:invalidReportDate];
}


- (BOOL)isYearly;
{
  return [KDateTypeYearly isEqualToString:_dateType];
}


- (NSArray *)missingReportDates:(NSArray *)filenames;
{
  NSDate *startingReportDate = [self startingReportDate];
  ReportFilenamePattern *reportFilenamePattern = [[ReportFilenamePattern alloc] initWithVendorID:[_vendor vendorID]
                                                                                      reportType:_reportType
                                                                                   reportSubType:_reportSubtype
                                                                                     andDateType:_dateType];
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
