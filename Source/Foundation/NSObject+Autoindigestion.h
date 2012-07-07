#import <Foundation/Foundation.h>


@interface NSObject (Autoindigestion)

+ (id)firstValueForKey:(NSString *)key
           fromObjects:(id)first, ...;

@end
