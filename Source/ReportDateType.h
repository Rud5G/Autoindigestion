#import <Foundation/Foundation.h>


@interface ReportDateType : NSObject

@property (readonly, copy) NSString *codeLetter;
@property (readonly, copy) NSString *name;

+ (instancetype)daily;

- (NSDate *)nextReportDateAfterDate:(NSDate *)date;

- (NSDate *)oldestReportDateBeforeDate:(NSDate *)date;

+ (instancetype)weekly;

+ (instancetype)yearly;

@end
