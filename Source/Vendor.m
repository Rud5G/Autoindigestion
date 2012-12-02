#import "Vendor.h"

#import "Autoingestion.h"
#import "ConfigurationFile.h"
#import "Defaults.h"
#import "Group.h"
#import "Monitor.h"
#import "NSObject+Autoindigestion.h"
#import "ReportCategory.h"
#import "User.h"
#import "VendorFile.h"


@implementation Vendor


- (NSArray *)autoingestionJobs;
{
  NSMutableArray *autoingestionJobs = [NSMutableArray array];
  for (ReportCategory *reportCategory in _reportCategories) {
    [autoingestionJobs addObjectsFromArray:[reportCategory autoingestionJobs]];
  }
  return autoingestionJobs;
}


- (id)initWithMonitor:(id<Monitor>)theMonitor
             defaults:(Defaults *)defaults
    configurationFile:(ConfigurationFile *)configurationFile
        autoingestion:(Autoingestion *)autoingestion
        andVendorFile:(VendorFile *)vendorFile;
{
  self = [super init];
  if ( ! self) return nil;

  _monitor = theMonitor;
  _reportCategories = [NSMutableArray array];

  if ( ! [vendorFile isValid]) {
    _disabled = YES;
    return self;
  }

  _group = [NSObject firstValueForKey:kGroupKey
                          fromObjects:vendorFile, configurationFile, defaults, nil];
  _owner = [NSObject firstValueForKey:kOwnerKey
                          fromObjects:vendorFile, configurationFile, defaults, nil];
  _fileMode = [defaults fileMode];

  _password = [vendorFile password];
  _username = [vendorFile username];
  _vendorID = [vendorFile vendorID];
  _vendorName = [vendorFile vendorName];

  NSNumber *disabledNumber = [NSObject firstValueForKey:kDisabledKey
                                            fromObjects:vendorFile, defaults, nil];
  _disabled = [disabledNumber boolValue];

  NSNumber *optInReportsEnabledNumber = [NSObject firstValueForKey:kOptInReportsEnabledKey
                                                       fromObjects:vendorFile, defaults, nil];
  _optInReportsEnabled = [optInReportsEnabledNumber boolValue];

  NSNumber *preOrderReportsEnabledNumber = [NSObject firstValueForKey:kPreOrderReportsEnabledKey
                                                          fromObjects:vendorFile, defaults, nil];
  _preOrderReportsEnabled = [preOrderReportsEnabledNumber boolValue];

  NSNumber *salesReportsDisabledNumber = [NSObject firstValueForKey:kSalesReportsDisabledKey
                                                        fromObjects:vendorFile, defaults, nil];
  _salesReportsDisabled = [salesReportsDisabledNumber boolValue];

  _reportDir = [vendorFile reportDir];
  if ( ! _reportDir) {
    _reportDir = [[defaults reportRoot] stringByAppendingPathComponent:_vendorName];
  }

  if (_optInReportsEnabled) {
    ReportCategory *weeklyOptIn = [[ReportCategory alloc] initWithMonitor:_monitor
                                                                 defaults:defaults
                                                            autoingestion:autoingestion
                                                                   vendor:self
                                                               reportType:kReportTypeSales
                                                                 dateType:kDateTypeWeekly
                                                         andReportSubtype:kReportSubtypeOptIn];
    [_reportCategories addObject:weeklyOptIn];
  }

  if (_preOrderReportsEnabled) {
    ReportCategory *dailyPreOrder = [[ReportCategory alloc] initWithMonitor:_monitor
                                                                   defaults:defaults
                                                              autoingestion:autoingestion
                                                                     vendor:self
                                                                 reportType:kReportTypePreOrder
                                                                   dateType:kDateTypeDaily
                                                           andReportSubtype:kReportSubtypeSummary];
    [_reportCategories addObject:dailyPreOrder];

    ReportCategory *weeklyPreOrder = [[ReportCategory alloc] initWithMonitor:_monitor
                                                                    defaults:defaults
                                                               autoingestion:autoingestion
                                                                      vendor:self
                                                                  reportType:kReportTypePreOrder
                                                                    dateType:kDateTypeWeekly
                                                            andReportSubtype:kReportSubtypeSummary];
    [_reportCategories addObject:weeklyPreOrder];
  }

  if ( ! _salesReportsDisabled) {
    ReportCategory *dailySales = [[ReportCategory alloc] initWithMonitor:_monitor
                                                                defaults:defaults
                                                           autoingestion:autoingestion
                                                                  vendor:self
                                                              reportType:kReportTypeSales
                                                                dateType:kDateTypeDaily
                                                        andReportSubtype:kReportSubtypeSummary];
    [_reportCategories addObject:dailySales];

    ReportCategory *weeklySales = [[ReportCategory alloc] initWithMonitor:_monitor
                                                                 defaults:defaults
                                                            autoingestion:autoingestion
                                                                   vendor:self
                                                               reportType:kReportTypeSales
                                                                 dateType:kDateTypeWeekly
                                                         andReportSubtype:kReportSubtypeSummary];
    [_reportCategories addObject:weeklySales];


  }

  if ( ! [_reportCategories count]) {
    [_monitor warningWithFormat:@"All reports are disabled for vendor \"%@\"", _vendorName];
    _disabled = YES;
  }

  return self;
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

  for (ReportCategory *reportCategory in _reportCategories) {
    [reportCategory prepare];
  }
}


@end
