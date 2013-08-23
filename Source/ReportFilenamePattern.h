#import "ReportCategory.h"


@interface ReportFilenamePattern : NSObject

@property (readonly) NSString *dateType;
@property (readonly) NSString *pattern;
@property (readonly) NSRegularExpression *regularExpression;
@property (readonly) NSString *reportSubType;
@property (readonly) NSString *reportType;
@property (readonly) NSString *vendorID;

- (id)initWithVendorID:(NSString *)vendorID
            reportType:(NSString *)reportType
         reportSubType:(NSString *)reportSubType
           andDateType:(NSString *)dateType;

- (NSArray *)reportDateStringsFromFilenames:(NSArray *)filenames;

- (NSArray *)reportFilenamesFromFilenames:(NSArray *)filenames;

@end
