#import <Foundation/Foundation.h>


@class Autoingestion;
@class Defaults;
@class Group;
@class ReportDateType;
@class User;
@class Vendor;

@protocol Monitor;


extern NSString *const kDateTypeDaily;
extern NSString *const kDateTypeWeekly;
extern NSString *const KDateTypeYearly;
extern NSString *const kReportSubtypeOptIn;
extern NSString *const kReportSubtypeSummary;
extern NSString *const kReportTypePreOrder;
extern NSString *const kReportTypeSales;


@interface ReportCategory : NSObject

@property (readonly) Autoingestion *autoingestion;
@property (readonly) NSDate *date;
@property (readonly) NSString *dateType;
@property (readonly) Defaults *defaults;
@property (readonly) NSNumber *fileMode;
@property (readonly) Group *group;
@property (readonly, weak) id<Monitor> monitor;
@property (readonly) User *owner;
@property (readonly) ReportDateType *reportDateType;
@property (readonly) NSString *reportDir;
@property (readonly) NSString *reportSubtype;
@property (readonly) NSString *reportType;
@property (readonly) NSDate *today;
@property (readonly, weak) Vendor *vendor;

- (NSArray *)autoingestionJobs;

- (id)initWithMonitor:(id<Monitor>)monitor
             defaults:(Defaults *)defaults
        autoingestion:(Autoingestion *)autoingestion
               vendor:(Vendor *)vendor
           reportType:(NSString *)reportType
       reportDateType:(ReportDateType *)reportDateType
        reportSubtype:(NSString *)reportSubtype
              andDate:(NSDate *)date;

- (BOOL)isDaily;

- (BOOL)isValidReportDate:(NSDate *)date;

- (BOOL)isWeekly;

- (BOOL)isYearly;

- (NSArray *)missingReportDates:(NSArray *)filenames;

- (NSDate *)nextReportDateAfterReportDate:(NSDate *)reportDate;

- (void)prepare;

- (NSDate *)startingReportDate;

@end
