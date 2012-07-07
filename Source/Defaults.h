#import <Foundation/Foundation.h>


@class Group;
@class User;

@protocol Monitor;


extern NSString *const kAutoingestionClassKey;
extern NSString *const kConfigurationFileKey;
extern NSString *const kDisabledKey;
extern NSString *const kFileModeKey;
extern NSString *const kGroupKey;
extern NSString *const kOptInReportsEnabledKey;
extern NSString *const kOwnerKey;
extern NSString *const kPasswordKey;
extern NSString *const kPreOrderReportsEnabledKey;
extern NSString *const kReportDirKey;
extern NSString *const kReportRootKey;
extern NSString *const kSalesReportsDisabledKey;
extern NSString *const kUsernameKey;
extern NSString *const kVendorsDirKey;
extern NSString *const kVendorIDKey;
extern NSString *const kVendorNameKey;


@interface Defaults : NSObject

@property (readonly) NSString *autoingestionClass;
@property (readonly) NSString *configurationFile;
@property (readonly) NSNumber *disabled;
@property (readonly) NSNumber *fileMode;
@property (readonly) Group *group;
@property (readonly) NSNumber *optInReportsEnabled;
@property (readonly) User *owner;
@property (readonly) NSNumber *preOrderReportsEnabled;
@property (readonly) NSString *reportRoot;
@property (readonly) NSNumber *salesReportsDisabled;
@property (readonly) NSString *vendorsDir;

- (id)initWithMonitor:(id<Monitor>)monitor;

@end
