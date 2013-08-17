#import <Foundation/Foundation.h>


@interface NSCalendar (Autoindigestion)

- (NSDate *)dateFromReportDate:(NSString *)reportDate;

- (NSDate *)fiveNewYearsAgoForDate:(NSDate *)date;

- (NSDate *)nextDayForDate:(NSDate *)date;

- (NSDate *)nextWeekForDate:(NSDate *)date;

- (NSDate *)nextYearForDate:(NSDate *)date;

- (NSDate *)previousDayForDate:(NSDate *)date;

- (NSDate *)previousSundayForDate:(NSDate *)date;

- (NSDate *)thirteenSundaysAgoForDate:(NSDate *)date;

- (NSDate *)twoWeeksAgoForDate:(NSDate *)date;

- (NSDate *)zeroOutTimeForDate:(NSDate *)date;

@end
