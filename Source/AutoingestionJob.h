#import <Foundation/Foundation.h>


@class ReportCategory;
@class AutoingestionResponse;
@protocol Monitor;


@interface AutoingestionJob : NSObject

@property (readonly) NSArray *arguments;
@property (readonly, weak) id<Monitor> monitor;
@property (readonly, weak) ReportCategory *reportCategory;
@property (readonly) NSDate *reportDate;
@property (readonly) AutoingestionResponse *response;

- (instancetype)initWithMonitor:(id <Monitor>)monitor
                 reportCategory:(ReportCategory *)reportCategory
                  andReportDate:(NSDate *)reportDate;

- (void)run;

- (AutoingestionResponse *)runTask;

@end
