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


@synthesize autoingestionClass;
@synthesize configurationFile;
@synthesize disabled;
@synthesize fileMode;
@synthesize group;
@synthesize optInReportsEnabled;
@synthesize owner;
@synthesize preOrderReportsEnabled;
@synthesize reportRoot;
@synthesize salesReportsDisabled;
@synthesize vendorsDir;


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
  NSString *libraryDir = [libraryDirs objectAtIndex:0];
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
  NSString *userDir = [userDirs objectAtIndex:0];
  NSString *sharedDir = [userDir stringByAppendingPathComponent:@"Shared"];

  autoingestionClass = [appDir stringByAppendingPathComponent:@"Autoingestion.class"];
  configurationFile = [appDir stringByAppendingPathComponent:@"Configuration.plist"];
  disabled = [NSNumber numberWithBool:NO];
  fileMode = [NSNumber numberWithShort:0775];
  optInReportsEnabled = [NSNumber numberWithBool:NO];
  preOrderReportsEnabled = [NSNumber numberWithBool:NO];
  reportRoot = [sharedDir stringByAppendingPathComponent:@"iTunes Connect"];
  salesReportsDisabled = [NSNumber numberWithBool:NO];
  vendorsDir = [appDir stringByAppendingPathComponent:@"Vendors"];

  NSError *error;
  group = [Group effectiveGroupWithError:&error];
  if ( ! group) {
    [monitor exitOnFailureWithError:error];
  }

  owner = [User effectiveUserWithError:&error];
  if ( ! owner) {
    [monitor exitOnFailureWithError:error];
  }

  return self;
}


@end
