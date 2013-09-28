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

  _path = [vendorFile copy];
  
  // TODO: use NSPropertyListSerialization to enable better error messages
  NSDictionary *configuration = [NSDictionary dictionaryWithContentsOfFile:_path];
  if ( ! configuration) {
    [monitor exitOnFailureWithFormat:@"Unable to read vendor configuration file \"%@\"",
             _path];
    return nil;
  }

  _disabled = configuration[kDisabledKey];
  _optInReportsEnabled = configuration[kOptInReportsEnabledKey];
  _password = [configuration[kPasswordKey] copy];
  _preOrderReportsEnabled = configuration[kPreOrderReportsEnabledKey];
  _reportDir = [configuration[kReportDirKey] copy];
  _salesReportsDisabled = configuration[kSalesReportsDisabledKey];
  _username = [configuration[kUsernameKey] copy];
  _vendorID = [configuration[kVendorIDKey] copy];
  _vendorName = [configuration[kVendorNameKey] copy];

  NSString *format = @"Configuration file \"%@\" is missing required key %@";
  if ( ! _password) [monitor warningWithFormat:format, _path, kPasswordKey];
  if ( ! _username) [monitor warningWithFormat:format, _path, kUsernameKey];
  if ( ! _vendorID) [monitor warningWithFormat:format, _path, kVendorIDKey];
  if ( ! _vendorName) [monitor warningWithFormat:format, _path, kVendorNameKey];

  NSString *groupName = configuration[kGroupKey];
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

  NSString *ownerName = configuration[kOwnerKey];
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
