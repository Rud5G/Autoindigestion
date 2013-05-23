#import <Foundation/Foundation.h>


@class Group;
@class User;
@protocol Monitor;


@interface VendorFile : NSObject

@property (readonly) NSNumber *disabled;
@property (readonly) Group *group;
@property (readonly) User *owner;
@property (readonly) NSNumber *optInReportsEnabled;
@property (readonly) NSString *password;
@property (readonly) NSString *path;
@property (readonly) NSNumber *preOrderReportsEnabled;
@property (readonly) NSString *reportDir;
@property (readonly) NSNumber *salesReportsDisabled;
@property (readonly) NSString *username;
@property (readonly) NSString *vendorID;
@property (readonly) NSString *vendorName;

- (id)initWithMonitor:(id <Monitor>)monitor
              andPath:(NSString *)vendorFile;

- (BOOL)isValid;

@end
