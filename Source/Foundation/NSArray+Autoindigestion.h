#import <Foundation/Foundation.h>


@interface NSArray (Autoindigestion)

- (NSArray *)filteredFilenamesUsingRegularExpression:(NSRegularExpression *)regularExpression;

@end
