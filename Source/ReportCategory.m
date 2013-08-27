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

static NSCalendar *calendar;
static NSLocale *locale;


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

  NSDate *startingReportDate = [self startingReportDate];
  ReportFilenamePattern *reportFilenamePattern = [[ReportFilenamePattern alloc] initWithVendorID:[_vendor vendorID]
                                                                                      reportType:_reportType
                                                                                   reportSubType:_reportSubtype
                                                                                     andDateType:_dateType];
  NSString *mostRecentExistingReportDateString = [reportFilenamePattern mostRecentReportDateStringFromFilenames:filenames];
  if (mostRecentExistingReportDateString) {
    NSDate *mostRecentExistingReportDate = [calendar dateFromReportDateString:mostRecentExistingReportDateString];
    if ([mostRecentExistingReportDate isMoreRecentThanDate:startingReportDate]) {
      startingReportDate = [self nextReportDateAfterReportDate:mostRecentExistingReportDate];
    }
  }

  NSMutableArray *autoingestionJobs = [NSMutableArray array];
  NSDate *reportDate = startingReportDate;
  while ([reportDate isLessRecentThanDate:_today]) {
    AutoingestionJob *autoingestionJob = [[AutoingestionJob alloc] initWithMonitor:_monitor
                                                                    reportCategory:self
                                                                     andReportDate:reportDate];
    [autoingestionJobs addObject:autoingestionJob];
    reportDate = [self nextReportDateAfterReportDate:reportDate];
  }

  return autoingestionJobs;
}


+ (void)initialize;
{
  if ([ReportCategory class] == self) {
    locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    calendar = [locale objectForKey:NSLocaleCalendar];
  }
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
  _today = [calendar zeroOutTimeForDate:[NSDate date]];
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


- (BOOL)isYearly;
{
  return [KDateTypeYearly isEqualToString:_dateType];
}


- (NSDate *)nextReportDateAfterReportDate:(NSDate *)reportDate;
{
  if ([self isDaily]) {
    return [calendar nextDayForDate:reportDate];
  } else if ([self isWeekly]) {
    return [calendar nextWeekForDate:reportDate];
  } else {
    return [calendar nextYearForDate:reportDate];
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
    return [calendar twoWeeksAgoForDate:_today];
  } else if ([self isWeekly]) {
    return [calendar thirteenSundaysAgoForDate:_today];
  } else {
    return [calendar fiveNewYearsDaysAgoForDate:_today];
  }
}


@end
