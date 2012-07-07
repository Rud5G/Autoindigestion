#import <Foundation/Foundation.h>


@class Defaults;
@class Group;
@class Options;
@class User;

@protocol Monitor;


@interface ConfigurationFile : NSObject

@property (readonly) NSString *autoingestionClass;
@property (readonly) Group *group;
@property (readonly) User *owner;
@property (readonly) NSString *vendorsDir;

- (id)initWithMonitor:(id <Monitor>)monitor
             defaults:(Defaults *)defaults
           andOptions:(Options *)options;

@end
