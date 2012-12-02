#import "Defaults.h"

#import "Group.h"
#import "Monitor.h"
#import "User.h"


NSString *const kAutoingestionClassKey = @"AutoingestionClass";
NSString *const kConfigurationFileKey = @"ConfigurationFile";
NSString *const kDisabledKey = @"Disabled";
NSString *const kFileModeKey = @"FileMode";
NSString *const kGroupKey = @"Group";
NSString *const kOptInReportsEnabledKey = @"OptInReportsEnabled";
NSString *const kOwnerKey = @"Owner";
NSString *const kPasswordKey = @"Password";
NSString *const kPreOrderReportsEnabledKey = @"PreOrderReportsEnabled";
NSString *const kReportDirKey = @"ReportDir";
NSString *const kReportRootKey = @"ReportRoot";
NSString *const kSalesReportsDisabledKey = @"SalesReportsDisabled";
NSString *const kUsernameKey = @"Username";
NSString *const kVendorsDirKey = @"VendorsDir";
NSString *const kVendorIDKey = @"VendorID";
NSString *const kVendorNameKey = @"VendorName";


@implementation Defaults


- (id)init;
{
  [NSException raise:@"Not Implemented" format:@"%s", __FUNCTION__];
  return nil;
}


- (id)initWithMonitor:(id<Monitor>)monitor;
{
  self = [super init];
  if ( ! self) return nil;

  NSArray *libraryDirs = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                             NSLocalDomainMask,
                                                             NO);
  if ( ! [libraryDirs count]) {
    [monitor exitOnFailureWithMessage:@"Did not find \"/Library\" directory"];
  } else if ([libraryDirs count] > 1) {
    [monitor exitOnFailureWithFormat:@"Found more than one \"/Library\" directory: %@",
             libraryDirs];
  }
  NSString *libraryDir = libraryDirs[0];
  NSString *appDir = [libraryDir stringByAppendingPathComponent:@"Autoindigestion"];

  NSArray *userDirs = NSSearchPathForDirectoriesInDomains(NSUserDirectory,
                                                          NSLocalDomainMask,
                                                          NO);
  if ( ! [userDirs count]) {
    [monitor exitOnFailureWithMessage:@"Did not find \"/Users\" directory"];
  } else if ([userDirs count] > 1) {
    [monitor exitOnFailureWithFormat:@"Found more than one \"/Users\" directory: %@",
             userDirs];
  }
  NSString *userDir = userDirs[0];
  NSString *sharedDir = [userDir stringByAppendingPathComponent:@"Shared"];

  _autoingestionClass = [appDir stringByAppendingPathComponent:@"Autoingestion.class"];
  _configurationFile = [appDir stringByAppendingPathComponent:@"Configuration.plist"];
  _disabled = @NO;
  _fileMode = @0775;
  _optInReportsEnabled = @NO;
  _preOrderReportsEnabled = @NO;
  _reportRoot = [sharedDir stringByAppendingPathComponent:@"iTunes Connect"];
  _salesReportsDisabled = @NO;
  _vendorsDir = [appDir stringByAppendingPathComponent:@"Vendors"];

  NSError *error;
  _group = [Group effectiveGroupWithError:&error];
  if ( ! _group) {
    [monitor exitOnFailureWithError:error];
  }

  _owner = [User effectiveUserWithError:&error];
  if ( ! _owner) {
    [monitor exitOnFailureWithError:error];
  }

  return self;
}


@end
