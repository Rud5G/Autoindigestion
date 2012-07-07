#import "Autoingestion.h"

#import "ConfigurationFile.h"
#import "Defaults.h"
#import "Monitor.h"
#import "NSObject+Autoindigestion.h"
#import "Options.h"


@implementation Autoingestion


@synthesize className;
@synthesize classPath;


- (id)initWithMonitor:(id <Monitor>)monitor
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

  className = [autoingestionClass lastPathComponent];
  if ([@"class" isEqualToString:[className pathExtension]]) {
    className = [className stringByDeletingPathExtension];
  }

  classPath = [autoingestionClass stringByDeletingLastPathComponent];

  return self;
}


@end
