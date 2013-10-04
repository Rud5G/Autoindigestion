#import <Foundation/Foundation.h>


@class Autoingestion;
@class Defaults;
@class Group;
@class ReportDateType;
@class User;
@class Vendor;

@protocol Monitor;


extern NSString *const kReportSubtypeOptIn;
extern NSString *const kReportSubtypeSummary;
extern NSString *const kReportTypePreOrder;
extern NSString *const kReportTypeSales;


@interface ReportCategory : NSObject

@property (readonly) Autoingestion *autoingestion;
@property (readonly) NSDate *date;
@property (readonly) Defaults *defaults;
@property (readonly) NSNumber *fileMode;
@property (readonly) Group *group;
@property (readonly, weak) id<Monitor> monitor;
@property (readonly) User *owner;
@property (readonly) ReportDateType *reportDateType;
@property (readonly, copy) NSString *reportDir;
@property (readonly, copy) NSString *reportSubtype;
@property (readonly, copy) NSString *reportType;
@property (readonly) NSDate *today;
@property (readonly, weak) Vendor *vendor;

- (NSArray *)autoingestionJobs;

- (instancetype)initWithMonitor:(id<Monitor>)monitor
                       defaults:(Defaults *)defaults
                  autoingestion:(Autoingestion *)autoingestion
                         vendor:(Vendor *)vendor
                     reportType:(NSString *)reportType
                 reportDateType:(ReportDateType *)reportDateType
                  reportSubtype:(NSString *)reportSubtype
                        andDate:(NSDate *)date;

- (BOOL)isValidReportDate:(NSDate *)date;

- (NSArray *)missingReportDates:(NSArray *)filenames;

- (void)prepare;

- (NSString *)reportDescriptionWithDate:(NSDate *)date;

@end
