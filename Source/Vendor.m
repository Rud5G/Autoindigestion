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


@synthesize disabled;
@synthesize fileMode;
@synthesize group;
@synthesize monitor;
@synthesize optInReportsEnabled;
@synthesize owner;
@synthesize password;
@synthesize preOrderReportsEnabled;
@synthesize reportDir;
@synthesize reportCategories;
@synthesize salesReportsDisabled;
@synthesize username;
@synthesize vendorID;
@synthesize vendorName;


- (NSArray *)autoingestionTasks;
{
  NSMutableArray *autoingestionTasks = [NSMutableArray array];
  for (ReportCategory *reportCategory in reportCategories) {
    [autoingestionTasks addObjectsFromArray:[reportCategory autoingestionTasks]];
  }
  return autoingestionTasks;
}


- (id)initWithMonitor:(id<Monitor>)theMonitor
             defaults:(Defaults *)defaults
    configurationFile:(ConfigurationFile *)configurationFile
        autoingestion:(Autoingestion *)autoingestion
        andVendorFile:(VendorFile *)vendorFile;
{
  self = [super init];
  if ( ! self) return nil;

  monitor = theMonitor;
  reportCategories = [NSMutableArray array];

  if ( ! [vendorFile isValid]) {
    disabled = YES;
    return self;
  }

  group = [NSObject firstValueForKey:kGroupKey
                         fromObjects:vendorFile, configurationFile, defaults, nil];
  owner = [NSObject firstValueForKey:kOwnerKey
                         fromObjects:vendorFile, configurationFile, defaults, nil];
  fileMode = [defaults fileMode];

  password = [vendorFile password];
  username = [vendorFile username];
  vendorID = [vendorFile vendorID];
  vendorName = [vendorFile vendorName];

  NSNumber *disabledNumber = [NSObject firstValueForKey:kDisabledKey
                                            fromObjects:vendorFile, defaults, nil];
  disabled = [disabledNumber boolValue];

  NSNumber *optInReportsEnabledNumber = [NSObject firstValueForKey:kOptInReportsEnabledKey
                                                       fromObjects:vendorFile, defaults, nil];
  optInReportsEnabled = [optInReportsEnabledNumber boolValue];

  NSNumber *preOrderReportsEnabledNumber = [NSObject firstValueForKey:kPreOrderReportsEnabledKey
                                                          fromObjects:vendorFile, defaults, nil];
  preOrderReportsEnabled = [preOrderReportsEnabledNumber boolValue];

  NSNumber *salesReportsDisabledNumber = [NSObject firstValueForKey:kSalesReportsDisabledKey
                                                        fromObjects:vendorFile, defaults, nil];
  salesReportsDisabled = [salesReportsDisabledNumber boolValue];

  reportDir = [vendorFile reportDir];
  if ( ! reportDir) {
    reportDir = [[defaults reportRoot] stringByAppendingPathComponent:vendorName];
  }

  if (optInReportsEnabled) {
    ReportCategory *weeklyOptIn = [[ReportCategory alloc] initWithMonitor:monitor
                                                                 defaults:defaults
                                                            autoingestion:autoingestion
                                                                   vendor:self
                                                               reportType:kReportTypeSales
                                                                 dateType:kDateTypeWeekly
                                                         andReportSubtype:kReportSubtypeOptIn];
    [reportCategories addObject:weeklyOptIn];
  }

  if (preOrderReportsEnabled) {
    ReportCategory *dailyPreOrder = [[ReportCategory alloc] initWithMonitor:monitor
                                                                   defaults:defaults
                                                              autoingestion:autoingestion
                                                                     vendor:self
                                                                 reportType:kReportTypePreOrder
                                                                   dateType:kDateTypeDaily
                                                           andReportSubtype:kReportSubtypeSummary];
    [reportCategories addObject:dailyPreOrder];

    ReportCategory *weeklyPreOrder = [[ReportCategory alloc] initWithMonitor:monitor
                                                                    defaults:defaults
                                                               autoingestion:autoingestion
                                                                      vendor:self
                                                                  reportType:kReportTypePreOrder
                                                                    dateType:kDateTypeWeekly
                                                            andReportSubtype:kReportSubtypeSummary];
    [reportCategories addObject:weeklyPreOrder];
  }

  if ( ! salesReportsDisabled) {
    ReportCategory *dailySales = [[ReportCategory alloc] initWithMonitor:monitor
                                                                defaults:defaults
                                                           autoingestion:autoingestion
                                                                  vendor:self
                                                              reportType:kReportTypeSales
                                                                dateType:kDateTypeDaily
                                                        andReportSubtype:kReportSubtypeSummary];
    [reportCategories addObject:dailySales];

    ReportCategory *weeklySales = [[ReportCategory alloc] initWithMonitor:monitor
                                                                 defaults:defaults
                                                            autoingestion:autoingestion
                                                                   vendor:self
                                                               reportType:kReportTypeSales
                                                                 dateType:kDateTypeWeekly
                                                         andReportSubtype:kReportSubtypeSummary];
    [reportCategories addObject:weeklySales];


  }

  if ( ! [reportCategories count]) {
    [monitor warningWithFormat:@"All reports are disabled for vendor \"%@\"", vendorName];
    disabled = YES;
  }

  return self;
}


- (void)prepare;
{
  if ( ! [[NSFileManager defaultManager] fileExistsAtPath:reportDir]) {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [owner ID], NSFileOwnerAccountID,
                                                 [group ID], NSFileGroupOwnerAccountID,
                                                 fileMode, NSFilePosixPermissions,
                                                 nil];
    NSError *error;
    BOOL created = [[NSFileManager defaultManager] createDirectoryAtPath:reportDir
                                             withIntermediateDirectories:YES
                                                              attributes:attributes
                                                                   error:&error];
    if ( ! created) {
      [monitor exitOnFailureWithError:error];
    }
  }

  for (ReportCategory *reportCategory in reportCategories) {
    [reportCategory prepare];
  }
}


@end
