#import <Foundation/Foundation.h>


@interface ReportDateType : NSObject

@property (readonly, copy) NSString *codeLetter;
@property (readonly) int dateStringLength;
@property (readonly, copy) NSString *name;

+ (instancetype)daily;

- (NSString *)formattedDateForDate:(NSDate *)date;

+ (instancetype)monthly;

- (NSDate *)nextReportDateAfterDate:(NSDate *)date;

- (NSDate *)oldestReportDateBeforeDate:(NSDate *)date;

+ (instancetype)weekly;

+ (instancetype)yearly;

@end
