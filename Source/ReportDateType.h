#import <Foundation/Foundation.h>


@interface ReportDateType : NSObject

@property (readonly, copy) NSString *codeLetter;
@property (readonly, copy) NSString *name;

+ (instancetype)daily;

+ (instancetype)weekly;

+ (instancetype)yearly;

@end
