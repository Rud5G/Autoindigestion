#import "ConfigurationFile.h"

#import "Defaults.h"
#import "Group.h"
#import "Monitor.h"
#import "NSObject+Autoindigestion.h"
#import "Options.h"
#import "User.h"


@implementation ConfigurationFile


@synthesize autoingestionClass;
@synthesize group;
@synthesize owner;
@synthesize vendorsDir;


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

  autoingestionClass = [configuration objectForKey:kAutoingestionClassKey];
  vendorsDir = [configuration objectForKey:kVendorsDirKey];

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


@end
