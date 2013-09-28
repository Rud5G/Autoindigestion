#import "ConfigurationFile.h"

#import "Defaults.h"
#import "Group.h"
#import "Monitor.h"
#import "NSObject+Autoindigestion.h"
#import "Options.h"
#import "User.h"


@implementation ConfigurationFile


- (id)init;
{
  [NSException raise:@"Not Implemented" format:@"%s", __FUNCTION__];
  return nil;
}


- (id)initWithMonitor:(id <Monitor>)monitor
             defaults:(Defaults *)defaults
           andOptions:(Options *)options;
{
  self = [super init];
  if ( ! self) return nil;

  NSString *configurationFile = [NSObject firstValueForKey:kConfigurationFileKey
                                               fromObjects:options, defaults, nil];
  if ( ! [[NSFileManager defaultManager] fileExistsAtPath:configurationFile]) {
    return self;
  }

  NSDictionary *configuration = [NSDictionary dictionaryWithContentsOfFile:configurationFile];
  if ( ! configuration) {
    [monitor exitOnFailureWithFormat:@"Unable to read configuration file \"%@\"",
             configurationFile];
    return nil;
  }

  _autoingestionClass = [configuration[kAutoingestionClassKey] copy];
  _vendorsDir = [configuration[kVendorsDirKey] copy];

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


@end
