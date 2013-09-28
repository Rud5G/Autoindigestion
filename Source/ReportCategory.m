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
  _defaults = defaults;
  _monitor = monitor;
  _reportDateType = reportDateType;
  _reportSubtype = [reportSubtype copy];
  _reportType = [reportType copy];
  _vendor = vendor;

  _fileMode = [_defaults fileMode];
  _group = [_vendor group];
  _owner = [_vendor owner];
  _today = [[NSCalendar POSIXCalendar] zeroOutTimeForDate:_date];

  if (   [kReportTypeSales isEqualToString:_reportType]
      && [kReportSubtypeOptIn isEqualToString:_reportSubtype])
  {
    _reportDir = [[[_vendor reportDir] stringByAppendingPathComponent:_reportSubtype] copy];
  } else {
    NSString *reportTypeDir = [[_vendor reportDir] stringByAppendingPathComponent:_reportType];
    _reportDir = [[reportTypeDir stringByAppendingPathComponent:[_reportDateType name]] copy];
  }

  return self;
}


- (BOOL)isValidReportDate:(NSDate *)date;
{
  NSDate *invalidReportDate = _today;
  if ([ReportDateType yearly] == _reportDateType) {
    invalidReportDate = [[NSCalendar POSIXCalendar] previousNewYearsDayForDate:_today];
  }
  return [date isLessRecentThanDate:invalidReportDate];
}


- (NSArray *)missingReportDates:(NSArray *)filenames;
{
  NSDate *firstDate = [_reportDateType oldestReportDateBeforeDate:_today];
  ReportFilenamePattern *reportFilenamePattern = [[ReportFilenamePattern alloc] initWithVendorID:[_vendor vendorID]
                                                                                      reportType:_reportType
                                                                                  reportDateType:_reportDateType
                                                                                andReportSubType:_reportSubtype];
  NSDate *mostRecentDate = [reportFilenamePattern mostRecentReportDateFromFilenames:filenames];
  if ([mostRecentDate isMoreRecentThanDate:firstDate]) {
    firstDate = ([_reportDateType nextReportDateAfterDate:mostRecentDate]);
  }
  
  NSMutableArray *missingReportDates = [NSMutableArray array];
  NSDate *missingReportDate = firstDate;
  while ([self isValidReportDate:missingReportDate]) {
    [missingReportDates addObject:missingReportDate];
    missingReportDate = ([_reportDateType nextReportDateAfterDate:missingReportDate]);
  }
  
  return missingReportDates;
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
