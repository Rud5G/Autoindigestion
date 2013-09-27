#import <Foundation/Foundation.h>


@class ReportDateType;


@interface ReportFilenamePattern : NSObject

@property (readonly) NSString *pattern;
@property (readonly) NSRegularExpression *regularExpression;
@property (readonly) ReportDateType *reportDateType;
@property (readonly) NSString *reportSubType;
@property (readonly) NSString *reportType;
@property (readonly) NSString *vendorID;

- (id)initWithVendorID:(NSString *)vendorID
            reportType:(NSString *)reportType
        reportDateType:(ReportDateType *)reportDateType
      andReportSubType:(NSString *)reportSubType;

- (NSDate *)mostRecentReportDateFromFilenames:(NSArray *)filenames;

- (NSArray *)reportDateStringsFromFilenames:(NSArray *)filenames;

- (NSArray *)reportFilenamesFromFilenames:(NSArray *)filenames;

@end
