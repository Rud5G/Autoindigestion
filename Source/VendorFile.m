#import "VendorFile.h"

#import "Defaults.h"
#import "Group.h"
#import "Monitor.h"
#import "User.h"


@implementation VendorFile


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

  _disabled = [configuration objectForKey:kDisabledKey];
  _optInReportsEnabled = [configuration objectForKey:kOptInReportsEnabledKey];
  _password = [configuration objectForKey:kPasswordKey];
  _preOrderReportsEnabled = [configuration objectForKey:kPreOrderReportsEnabledKey];
  _reportDir = [configuration objectForKey:kReportDirKey];
  _salesReportsDisabled = [configuration objectForKey:kSalesReportsDisabledKey];
  _username = [configuration objectForKey:kUsernameKey];
  _vendorID = [configuration objectForKey:kVendorIDKey];
  _vendorName = [configuration objectForKey:kVendorNameKey];

  NSString *format = @"Configuration file \"%@\" is missing required key %@";
  if ( ! _password) [monitor warningWithFormat:format, vendorFile, kPasswordKey];
  if ( ! _username) [monitor warningWithFormat:format, vendorFile, kUsernameKey];
  if ( ! _vendorID) [monitor warningWithFormat:format, vendorFile, kVendorIDKey];
  if ( ! _vendorName) [monitor warningWithFormat:format, vendorFile, kVendorNameKey];

  NSString *groupName = [configuration objectForKey:kGroupKey];
  if (groupName) {
    NSError *error;
    _group = [[Group alloc] initWithName:groupName error:&error];
    if ( ! _group) {
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
    _owner = [[User alloc] initWithName:ownerName error:&error];
    if ( ! _owner) {
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
  return (_password && _username && _vendorID && _vendorName) ? YES : NO;
}


@end
