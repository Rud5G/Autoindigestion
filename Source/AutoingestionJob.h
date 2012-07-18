#import <Foundation/Foundation.h>


@class ReportCategory;
@protocol Monitor;


enum AutoingestionResponseCode {
  AutoingestionResponseCodeNone = 0,
  AutoingestionResponseCodeSuccess,
  AutoingestionResponseCodeNotAvailable,
  AutoingestionResponseCodeNoReportsAvailable,
  AutoingestionResponseCodeTryAgain,
  AutoingestionResponseCodeDailyReportDateOutOfRange,
  AutoingestionResponseCodeWeeklyReportDateOutOfRange,
  AutoingestionResponseCodeUnknownHostException,
  AutoingestionResponseCodeUnrecognized,
};


extern NSString *const kAutoingestionResponseNotAvailable;
extern NSString *const kAutoingestionResponseNoReportsAvailable;
extern NSString *const kAutoingestionResponseTryAgain;
extern NSString *const kAutoingestionResponseSuccess;
extern NSString *const kAutoingestionResponseDailyReportDateOutOfRange;
extern NSString *const kAutoingestionResponseWeeklyReportDateOutOfRange;
extern NSString *const kAutoingestionResponseUnknownHostException;


@interface AutoingestionJob : NSObject

@property (readonly) NSArray *arguments;
@property (readonly, weak) id<Monitor> monitor;
@property (readonly, weak) ReportCategory *reportCategory;
@property (readonly) NSDate *reportDate;
@property (readonly) enum AutoingestionResponseCode responseCode;

- (id)initWithMonitor:(id <Monitor>)theMonitor
       reportCategory:(ReportCategory *)theReportCategory
        andReportDate:(NSDate *)theReportDate;

- (enum AutoingestionResponseCode)responseCodeFromResponse:(NSString *)response;

- (void)run;

- (NSString *)runTask;

@end
