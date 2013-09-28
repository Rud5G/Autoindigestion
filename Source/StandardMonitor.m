#import "StandardMonitor.h"


static NSString *stringWithFormatAndArguments(NSString *format, va_list arguments);


@implementation StandardMonitor


- (void)exitOnFailureWithError:(NSError *)error;
{
  [self exitOnFailureWithMessage:[error localizedDescription]];
}


- (void)exitOnFailureWithFormat:(NSString *)format, ...;
{
  va_list arguments;
  va_start(arguments, format);

  NSString *message = stringWithFormatAndArguments(format, arguments);
  [self exitOnFailureWithMessage:message];
  
  va_end(arguments);
}


- (void)exitOnFailureWithMessage:(NSString *)message;
{
  [self writeLogMessage:message toFile:stderr];
  exit(EXIT_FAILURE);
}


- (void)exitWithUsage:(NSString *)format, ...;
{
  va_list arguments;
  va_start(arguments, format);
  
  NSString *message = stringWithFormatAndArguments(format, arguments);
  [self writeMessage:message toFile:stderr];
  
  va_end(arguments);
  exit(EXIT_FAILURE);
}


- (void)infoWithFormat:(NSString *)format, ...;
{
  va_list arguments;
  va_start(arguments, format);
  
  NSString *message = stringWithFormatAndArguments(format, arguments);
  [self infoWithMessage:message];
  
  va_end(arguments);
}


- (void)infoWithMessage:(NSString *)message;
{
  [self writeLogMessage:message toFile:stdout];
}


- (instancetype)init;
{
  [NSException raise:@"Not Implemented" format:@"%s", __FUNCTION__];
  return nil;
}


- (instancetype)initWithArgumentList:(char *[])argv;
{
  self = [super init];
  if (!self) return nil;

  NSString *commandPath = [NSString stringWithCString:argv[0]
                                             encoding:NSUTF8StringEncoding];
  _command = [[commandPath lastPathComponent] copy];

  _dateFormatter = [[NSDateFormatter alloc] init];
  [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
  NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  [_dateFormatter setLocale:locale];

  return self;
}


- (void)warningWithError:(NSError *)error;
{
  [self warningWithMessage:[error localizedDescription]];
}


- (void)warningWithFormat:(NSString *)format, ...;
{
  va_list arguments;
  va_start(arguments, format);
  
  NSString *message = stringWithFormatAndArguments(format, arguments);
  [self warningWithMessage:message];
  
  va_end(arguments);
}


- (void)warningWithMessage:(NSString *)message;
{
  [self writeLogMessage:message toFile:stderr];
}


- (void)writeMessage:(NSString *)message
              toFile:(FILE *)file;
{
  char const *end = [message hasSuffix:@"\n"] ? "" : "\n";
  fprintf(file, "%s%s", [message UTF8String], end);
}


- (void)writeLogMessage:(NSString *)message
                 toFile:(FILE *)file;
{
  NSString *timestamp = [_dateFormatter stringFromDate:[NSDate date]];
  char const *end = [message hasSuffix:@"\n"] ? "" : "\n";
  fprintf(file, "%s %s: %s%s",
          [timestamp UTF8String], [_command UTF8String], [message UTF8String], end);
}


@end


static NSString *stringWithFormatAndArguments(NSString *format, va_list arguments)
{
  
# pragma clang diagnostic push
# pragma clang diagnostic ignored "-Wformat-nonliteral"

  return [[NSString alloc] initWithFormat:format
                                arguments:arguments];
  
# pragma clang diagnostic pop
  
}
