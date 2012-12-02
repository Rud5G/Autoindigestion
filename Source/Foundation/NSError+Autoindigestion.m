#import "NSError+Autoindigestion.h"


@implementation NSError (Autoindigestion)


+ (id)currentPOSIXError;
{
  NSString *localizedDescription = [NSString stringWithCString:strerror(errno)
                                                      encoding:NSUTF8StringEncoding];
  NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : localizedDescription };
  return [self errorWithDomain:NSPOSIXErrorDomain
                          code:errno
                      userInfo:userInfo];
}


@end
