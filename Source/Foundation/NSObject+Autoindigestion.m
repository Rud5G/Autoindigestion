#import "NSObject+Autoindigestion.h"


@implementation NSObject (Autoindigestion)


+ (id)firstValueForKey:(NSString *)key
           fromObjects:(id)first, ...;
{
  NSString *firstLetter = [key substringToIndex:1];
  NSString *alternateKey = [[firstLetter lowercaseString] stringByAppendingString:[key substringFromIndex:1]];

  va_list arguments;
  va_start(arguments, first);

  id object = first;
  while (object) {
    @try {
      id value = [object valueForKey:key];
      if (value) return value;
    } @catch (id /*exception*/) {
      // ignore
    }

    @try {
      id value = [object valueForKey:alternateKey];
      if (value) return value;
    } @catch (id /*exception*/) {
      // ignore
    }

    object = va_arg(arguments, id);
  }

  va_end(arguments);
  return nil;
}


@end
