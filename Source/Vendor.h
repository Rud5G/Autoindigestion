#import <Foundation/Foundation.h>


@class Autoingestion;
@class ConfigurationFile;
@class Defaults;
@class Group;
@class Options;
@class User;
@class VendorFile;
@protocol Monitor;


@interface Vendor : NSObject

@property (readonly) NSString *credentialsFilePath;
@property (readonly) NSDate *date;
@property (readonly) BOOL disabled;
@property (readonly) NSNumber *fileMode;
@property (readonly) Group *group;
@property (weak, readonly) id<Monitor> monitor;
@property (readonly) BOOL optInReportsEnabled;
@property (readonly) User *owner;
@property (readonly) NSString *password;
@property (readonly) BOOL preOrderReportsEnabled;
@property (readonly) NSString *reportDir;
@property (readonly) NSMutableArray *reportCategories;
@property (readonly) BOOL salesReportsDisabled;
@property (readonly) NSString *username;
@property (readonly) NSString *vendorID;
@property (readonly) NSString *vendorName;

- (NSArray *)autoingestionJobs;

- (void)cleanUp;

- (id)initWithMonitor:(id<Monitor>)theMonitor
             defaults:(Defaults *)defaults
    configurationFile:(ConfigurationFile *)configurationFile
        autoingestion:(Autoingestion *)autoingestion
        andVendorFile:(VendorFile *)vendorFile;

- (void)prepare;

@end
