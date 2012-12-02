#import "NSString+Autoindigestion.h"


@implementation NSString (Autoindigestion)


- (BOOL)containsString:(NSString *)string;
{
  NSRange range = [self rangeOfString:string];
  return range.location != NSNotFound;
}


- (BOOL)isParentOfPath:(NSString *)path;
{
  NSArray *parent = [self pathComponents];
  NSArray *child = [path pathComponents];
  if ([parent count] >= [child count]) return NO;
  
  for (NSUInteger i = 0; i < [parent count]; ++i) {
    if ( ! [parent[i] isEqualToString:child[i]]) {
      return NO;
    }
  }
  return YES;
}


@end
