#import "VendorFile.h"

#import "Defaults.h"
#import "Group.h"
#import "Monitor.h"
#import "User.h"


@implementation VendorFile


@synthesize disabled;
@synthesize group;
@synthesize optInReportsEnabled;
@synthesize owner;
@synthesize password;
@synthesize preOrderReportsEnabled;
@synthesize reportDir;
@synthesize salesReportsDisabled;
@synthesize username;
@synthesize vendorID;
@synthesize vendorName;


- (id)initWithMonitor:(id <Monitor>)monitor
              andPath:(NSString *)vendorFile;
{
  self = [super init];
  if ( ! self) return nil;

  NSDictionary *configuration = [NSDictionary dictionaryWithContentsOfFile:vendorFile];
  if ( ! configuration) {
    [monitor exitOnFailureWithFormat:@"Unable to read vendor configuration file \"%@\"",
             vendorFile];
    return nil;
  }

  disabled = [configuration objectForKey:kDisabledKey];
  optInReportsEnabled = [configuration objectForKey:kOptInReportsEnabledKey];
  password = [configuration objectForKey:kPasswordKey];
  preOrderReportsEnabled = [configuration objectForKey:kPreOrderReportsEnabledKey];
  reportDir = [configuration objectForKey:kReportDirKey];
  salesReportsDisabled = [configuration objectForKey:kSalesReportsDisabledKey];
  username = [configuration objectForKey:kUsernameKey];
  vendorID = [configuration objectForKey:kVendorIDKey];
  vendorName = [configuration objectForKey:kVendorNameKey];

  NSString *format = @"Configuration file \"%@\" is missing required key %@";
  if ( ! password) [monitor warningWithFormat:format, vendorFile, kPasswordKey];
  if ( ! username) [monitor warningWithFormat:format, vendorFile, kUsernameKey];
  if ( ! vendorID) [monitor warningWithFormat:format, vendorFile, kVendorIDKey];
  if ( ! vendorName) [monitor warningWithFormat:format, vendorFile, kVendorNameKey];

  NSString *groupName = [configuration objectForKey:kGroupKey];
  if (groupName) {
    NSError *error;
    group = [[Group alloc] initWithName:groupName error:&error];
    if ( ! group) {
      if (error) {
        [monitor exitOnFailureWithError:error];
      } else {
        [monitor exitOnFailureWithFormat:@"Group \"%@\" not found", groupName];
      }
      return nil;
    }
  }

  NSString *ownerName = [configuration objectForKey:kOwnerKey];
  if (ownerName) {
    NSError *error;
    owner = [[User alloc] initWithName:ownerName error:&error];
    if ( ! owner) {
      if (error) {
        [monitor exitOnFailureWithError:error];
      } else {
        [monitor exitOnFailureWithFormat:@"User \"%@\" not found", ownerName];
      }
    }
  }

  return self;
}


- (BOOL)isValid;
{
  return (password && username && vendorID && vendorName) ? YES : NO;
}


@end
