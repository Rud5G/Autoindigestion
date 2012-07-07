#import <Foundation/Foundation.h>


@class ReportCategory;
@protocol Monitor;


extern NSString *const kAutoingestionResponseNotAvailable;
extern NSString *const kAutoingestionResponseNoReportsAvailable;
extern NSString *const kAutoingestionResponseTryAgain;
extern NSString *const kAutoingestionResponseSuccess;
extern NSString *const kAutoingestionResponseDailyReportDateOutOfRange;
extern NSString *const kAutoingestionResponseWeeklyReportDateOutOfRange;


@interface AutoingestionJob : NSObject

@property (readonly) NSDateFormatter *arugmentDateFormatter;
@property (readonly) NSDateFormatter *descriptionDateFormatter;
@property (readonly, weak) id<Monitor> monitor;
@property (readonly, weak) ReportCategory *reportCategory;
@property (readonly) NSDate *reportDate;
@property (readonly) NSTask *task;

- (id)initWithMonitor:(id <Monitor>)theMonitor
       reportCategory:(ReportCategory *)theReportCategory
        andReportDate:(NSDate *)theReportDate;

- (void)run;

@end
