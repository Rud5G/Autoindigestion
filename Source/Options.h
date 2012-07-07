#import <Foundation/Foundation.h>


@class Defaults;
@protocol Monitor;


@interface Options : NSObject

@property (readonly) NSString *autoingestionClass;
@property (readonly) NSString *configurationFile;
@property (readonly) Defaults *defaults;
@property (readonly, weak) id<Monitor> monitor;
@property (readonly) NSString *vendorsDir;

- (id)initWithMonitor:(id <Monitor>)theMonitor
             defaults:(Defaults *)theDefaults
        argumentCount:(int)argc
      andArgumentList:(char *[])argv;

- (void)printUsageAndExit;

@end
