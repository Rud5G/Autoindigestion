#import <Foundation/Foundation.h>


@class ConfigurationFile;
@class Defaults;
@class Options;
@protocol Monitor;


@interface Autoingestion : NSObject

@property (readonly) NSString *className;
@property (readonly) NSString *classPath;

- (id)initWithMonitor:(id <Monitor>)monitor
             defaults:(Defaults *)defaults
              options:(Options *)options
 andConfigurationFile:(ConfigurationFile *)configurationFile;

@end
