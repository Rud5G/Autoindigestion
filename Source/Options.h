#import <Foundation/Foundation.h>


@class Defaults;
@protocol Monitor;


@interface Options : NSObject

@property (readonly, copy) NSString *autoingestionClass;
@property (readonly, copy) NSString *configurationFile;
@property (readonly) Defaults *defaults;
@property (readonly, weak) id<Monitor> monitor;
@property (readonly, copy) NSString *vendorsDir;

- (instancetype)initWithMonitor:(id <Monitor>)theMonitor
                       defaults:(Defaults *)theDefaults
                  argumentCount:(int)argc
                andArgumentList:(char *[])argv;

- (void)printUsageAndExit;

@end
