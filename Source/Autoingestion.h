#import <Foundation/Foundation.h>


@class ConfigurationFile;
@class Defaults;
@class Options;
@protocol Monitor;


@interface Autoingestion : NSObject

@property (readonly, copy) NSString *className;
@property (readonly, copy) NSString *classPath;

- (instancetype)initWithMonitor:(id <Monitor>)monitor
                       defaults:(Defaults *)defaults
                        options:(Options *)options
           andConfigurationFile:(ConfigurationFile *)configurationFile;

@end
