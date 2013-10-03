#import "Vendor.h"

#import "Autoingestion.h"
#import "ConfigurationFile.h"
#import "Defaults.h"
#import "Group.h"
#import "Monitor.h"
#import "NSObject+Autoindigestion.h"
#import "ReportCategory.h"
#import "ReportDateType.h"
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


- (void)cleanUp;
{
  NSError *error;
  BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:_credentialsFilePath
                                                            error:&error];
  if ( ! removed) {
    [_monitor warningWithError:error];
  }
}


- (instancetype)init;
{
  [NSException raise:@"Not Implemented" format:@"%s", __FUNCTION__];
  return nil;
}


- (instancetype)initWithMonitor:(id<Monitor>)theMonitor
                       defaults:(Defaults *)defaults
              configurationFile:(ConfigurationFile *)configurationFile
                  autoingestion:(Autoingestion *)autoingestion
                  andVendorFile:(VendorFile *)vendorFile;
{
  self = [super init];
  if ( ! self) return nil;

  _date = [NSDate date];
  _monitor = theMonitor;
  _reportCategories = [NSMutableArray array];

  if ( ! [vendorFile isValid]) {
    _disabled = YES;
    return self;
  }
  
  _credentialsFilePath = [[[[vendorFile path] stringByDeletingPathExtension]
                              stringByAppendingPathExtension:@"properties"] copy];
  
  _group = [NSObject firstValueForKey:kGroupKey
                          fromObjects:vendorFile, configurationFile, defaults, nil];
  _owner = [NSObject firstValueForKey:kOwnerKey
                          fromObjects:vendorFile, configurationFile, defaults, nil];
  _fileMode = [defaults fileMode];

  _password = [[vendorFile password] copy];
  _username = [[vendorFile username] copy];
  _vendorID = [[vendorFile vendorID] copy];
  _vendorName = [[vendorFile vendorName] copy];

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

  _reportDir = [[vendorFile reportDir] copy];
  if ( ! _reportDir) {
    _reportDir = [[[defaults reportRoot] stringByAppendingPathComponent:_vendorName] copy];
  }

  if (_optInReportsEnabled) {
    ReportCategory *weeklyOptIn = [[ReportCategory alloc] initWithMonitor:_monitor
                                                                 defaults:defaults
                                                            autoingestion:autoingestion
                                                                   vendor:self
                                                               reportType:kReportTypeSales
                                                           reportDateType:[ReportDateType weekly]
                                                            reportSubtype:kReportSubtypeOptIn
                                                                  andDate:_date];
    [_reportCategories addObject:weeklyOptIn];
  }

  if (_preOrderReportsEnabled) {
    ReportCategory *dailyPreOrder = [[ReportCategory alloc] initWithMonitor:_monitor
                                                                   defaults:defaults
                                                              autoingestion:autoingestion
                                                                     vendor:self
                                                                 reportType:kReportTypePreOrder
                                                             reportDateType:[ReportDateType daily]
                                                              reportSubtype:kReportSubtypeSummary
                                                                    andDate:_date];
    [_reportCategories addObject:dailyPreOrder];

    ReportCategory *weeklyPreOrder = [[ReportCategory alloc] initWithMonitor:_monitor
                                                                    defaults:defaults
                                                               autoingestion:autoingestion
                                                                      vendor:self
                                                                  reportType:kReportTypePreOrder
                                                              reportDateType:[ReportDateType weekly]
                                                               reportSubtype:kReportSubtypeSummary
                                                                     andDate:_date];
    [_reportCategories addObject:weeklyPreOrder];
  }

  if ( ! _salesReportsDisabled) {
    ReportCategory *dailySales = [[ReportCategory alloc] initWithMonitor:_monitor
                                                                defaults:defaults
                                                           autoingestion:autoingestion
                                                                  vendor:self
                                                              reportType:kReportTypeSales
                                                          reportDateType:[ReportDateType daily]
                                                           reportSubtype:kReportSubtypeSummary
                                                                 andDate:_date];
    [_reportCategories addObject:dailySales];

    ReportCategory *weeklySales = [[ReportCategory alloc] initWithMonitor:_monitor
                                                                 defaults:defaults
                                                            autoingestion:autoingestion
                                                                   vendor:self
                                                               reportType:kReportTypeSales
                                                           reportDateType:[ReportDateType weekly]
                                                            reportSubtype:kReportSubtypeSummary
                                                                  andDate:_date];
    [_reportCategories addObject:weeklySales];

    ReportCategory *monthlySales = [[ReportCategory alloc] initWithMonitor:_monitor
                                                                  defaults:defaults
                                                             autoingestion:autoingestion
                                                                    vendor:self
                                                                reportType:kReportTypeSales
                                                            reportDateType:[ReportDateType monthly]
                                                             reportSubtype:kReportSubtypeSummary
                                                                   andDate:_date];
    [_reportCategories addObject:monthlySales];

    ReportCategory *yearlySales = [[ReportCategory alloc] initWithMonitor:_monitor
                                                                 defaults:defaults
                                                            autoingestion:autoingestion
                                                                   vendor:self
                                                               reportType:kReportTypeSales
                                                           reportDateType:[ReportDateType yearly]
                                                            reportSubtype:kReportSubtypeSummary
                                                                  andDate:_date];
    [_reportCategories addObject:yearlySales];
  }

  if ( ! [_reportCategories count]) {
    [_monitor warningWithFormat:@"All reports are disabled for vendor \"%@\"", _vendorName];
    _disabled = YES;
  }

  return self;
}


- (void)prepare;
{
  NSString *credentials = [NSString stringWithFormat:
                           @"userID = %@\npassword = %@\n",
                           _username, _password];
  NSError *error;
  BOOL written = [credentials writeToFile:_credentialsFilePath
                               atomically:YES
                                 encoding:NSUTF8StringEncoding
                                    error:&error];
  if ( ! written) {
    [_monitor exitOnFailureWithError:error];
  }
  
  NSDictionary *attributes = @{ NSFilePosixPermissions : @0600 };
  BOOL wasSet = [[NSFileManager defaultManager] setAttributes:attributes
                                                 ofItemAtPath:_credentialsFilePath
                                                        error:&error];
  if ( ! wasSet) {
    [_monitor exitOnFailureWithError:error];
  }
  
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
