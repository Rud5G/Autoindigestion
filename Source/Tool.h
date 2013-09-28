#import <Foundation/Foundation.h>


@class Autoingestion;
@class ConfigurationFile;
@class Defaults;
@class Group;
@class Options;
@class User;

@protocol Monitor;


@interface Tool : NSObject

@property (readonly) Autoingestion *autoingestion;
@property (readonly) NSNumber *fileMode;
@property (readonly) Group *group;
@property (readonly, weak) id<Monitor> monitor;
@property (readonly) User *owner;
@property (readonly, copy) NSString *reportRoot;
@property (readonly, copy) NSMutableArray *vendors;

- (void)cleanUp;

- (id)initWithMonitor:(id <Monitor>)theMonitor
             defaults:(Defaults *)defaults
    configurationFile:(ConfigurationFile *)configurationFile
           andOptions:(Options *)options;

- (void)prepare;

- (void)downloadReports;

@end
