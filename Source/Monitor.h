#import <Foundation/Foundation.h>


@protocol Monitor <NSObject>

@property (readonly) NSString *command;

- (void)exitOnFailureWithError:(NSError *)error;

- (void)exitOnFailureWithFormat:(NSString *)format, ...;

- (void)exitOnFailureWithMessage:(NSString *)message;

- (void)exitWithUsage:(NSString *)format, ...;

- (void)infoWithFormat:(NSString *)format, ...;

- (void)infoWithMessage:(NSString *)message;

- (void)warningWithError:(NSError *)error;

- (void)warningWithFormat:(NSString *)format, ...;

- (void)warningWithMessage:(NSString *)message;

@end
