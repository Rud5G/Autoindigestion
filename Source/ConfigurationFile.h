#import <Foundation/Foundation.h>


@class Defaults;
@class Group;
@class Options;
@class User;

@protocol Monitor;


@interface ConfigurationFile : NSObject

@property (readonly, copy) NSString *autoingestionClass;
@property (readonly) Group *group;
@property (readonly) User *owner;
@property (readonly, copy) NSString *vendorsDir;

- (instancetype)initWithMonitor:(id <Monitor>)monitor
                       defaults:(Defaults *)defaults
                     andOptions:(Options *)options;

@end
