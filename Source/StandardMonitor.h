#import <Foundation/Foundation.h>
#import "Monitor.h"


@interface StandardMonitor : NSObject <Monitor>

@property (readonly, copy) NSString *command;
@property (readonly) NSDateFormatter *dateFormatter;

- (id)initWithArgumentList:(char *[])argv;

- (void)writeMessage:(NSString *)message
              toFile:(FILE *)file;

- (void)writeLogMessage:(NSString *)message
                 toFile:(FILE *)file;

@end
