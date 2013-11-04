#import "SenTestCase+Date.h"


static NSLocale *posixLocale;
dispatch_once_t posixLocaleOnce;


@implementation SenTestCase (Date)


- (NSDate *)date:(NSString *)dateString;
{
  dispatch_once(&posixLocaleOnce, ^{
    posixLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  });
  return [NSDate dateWithNaturalLanguageString:dateString
                                        locale:posixLocale];
}


@end
