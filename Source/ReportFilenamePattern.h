#import <Foundation/Foundation.h>


@class ReportDateType;


@interface ReportFilenamePattern : NSObject

@property (readonly, copy) NSString *pattern;
@property (readonly) NSRegularExpression *regularExpression;
@property (readonly) ReportDateType *reportDateType;
@property (readonly, copy) NSString *reportSubType;
@property (readonly, copy) NSString *reportType;
@property (readonly, copy) NSString *vendorID;

- (id)initWithVendorID:(NSString *)vendorID
            reportType:(NSString *)reportType
        reportDateType:(ReportDateType *)reportDateType
      andReportSubType:(NSString *)reportSubType;

- (NSDate *)mostRecentReportDateFromFilenames:(NSArray *)filenames;

- (NSArray *)reportDateStringsFromFilenames:(NSArray *)filenames;

- (NSArray *)reportFilenamesFromFilenames:(NSArray *)filenames;

@end
