#import <Foundation/Foundation.h>


@class Autoingestion;
@class Defaults;
@class Group;
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
@property (readonly) NSString *dateType;
@property (readonly) Defaults *defaults;
@property (readonly) NSNumber *fileMode;
@property (readonly) Group *group;
@property (readonly, weak) id<Monitor> monitor;
@property (readonly) User *owner;
@property (readonly) NSString *reportDir;
@property (readonly) NSString *reportSubtype;
@property (readonly) NSString *reportType;
@property (readonly) NSDate *today;
@property (readonly, weak) Vendor *vendor;

- (NSArray *)autoingestionJobs;

- (id)initWithMonitor:(id <Monitor>)theMonitor
             defaults:(Defaults *)theDefaults
        autoingestion:(Autoingestion *)theAutoingestion
               vendor:(Vendor *)theVendor
           reportType:(NSString *)theReportType
             dateType:(NSString *)theDateType
     andReportSubtype:(NSString *)theReportSubtype;

- (BOOL)isDaily;

- (BOOL)isWeekly;

- (BOOL)isYearly;

- (void)prepare;

- (NSDate *)startingReportDate;

@end
