#import "Autoingestion.h"

#import "ConfigurationFile.h"
#import "Defaults.h"
#import "Monitor.h"
#import "NSObject+Autoindigestion.h"
#import "Options.h"


@implementation Autoingestion


- (instancetype)init;
{
  [NSException raise:@"Not Implemented" format:@"%s", __FUNCTION__];
  return nil;
}


- (instancetype)initWithMonitor:(id <Monitor>)monitor
                       defaults:(Defaults *)defaults
                        options:(Options *)options
           andConfigurationFile:(ConfigurationFile *)configurationFile;
{
  self = [super init];
  if ( ! self) return nil;

  NSString *autoingestionClass = [NSObject firstValueForKey:kAutoingestionClassKey
                                                fromObjects:options, configurationFile, defaults, nil];
  if ( ! [[NSFileManager defaultManager] fileExistsAtPath:autoingestionClass]) {
    [monitor exitOnFailureWithFormat:@"Autoingestion class not found at \"%@\"",
             autoingestionClass];
    return nil;
  }

  _className = [[autoingestionClass lastPathComponent] copy];
  if ([@"class" isEqualToString:[_className pathExtension]]) {
    _className = [[_className stringByDeletingPathExtension] copy];
  }

  _classPath = [[autoingestionClass stringByDeletingLastPathComponent] copy];

  return self;
}


@end
