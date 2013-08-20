#import "NSArray+Autoindigestion.h"


@implementation NSArray (Autoindigestion)


- (NSArray *)filteredFilenamesUsingRegularExpression:(NSRegularExpression *)regularExpression;
{
  NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
    NSString *filename = evaluatedObject;
    NSRange range = NSMakeRange(0, [filename length]);
    NSTextCheckingResult *textCheckingResult = [regularExpression firstMatchInString:filename
                                                                             options:0
                                                                               range:range];
    return [textCheckingResult numberOfRanges] > 0;
  }];
  NSArray *matchingFilenames = [self filteredArrayUsingPredicate:predicate];
  return [matchingFilenames sortedArrayUsingSelector:@selector(compare:)];
}


@end
