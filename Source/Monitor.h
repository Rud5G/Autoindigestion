#import <Foundation/Foundation.h>


@protocol Monitor <NSObject>

@property (readonly, copy) NSString *command;

- (void)exitOnFailureWithError:(NSError *)error;

- (void)exitOnFailureWithFormat:(NSString *)format, ...;

- (void)exitOnFailureWithMessage:(NSString *)message __attribute__ ((noreturn));

- (void)exitWithUsage:(NSString *)format, ... __attribute__ ((noreturn));

- (void)infoWithFormat:(NSString *)format, ...;

- (void)infoWithMessage:(NSString *)message;

- (void)warningWithError:(NSError *)error;

- (void)warningWithFormat:(NSString *)format, ...;

- (void)warningWithMessage:(NSString *)message;

@end
