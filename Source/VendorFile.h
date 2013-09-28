#import <Foundation/Foundation.h>


@class Group;
@class User;
@protocol Monitor;


@interface VendorFile : NSObject

@property (readonly) NSNumber *disabled;
@property (readonly) Group *group;
@property (readonly) User *owner;
@property (readonly) NSNumber *optInReportsEnabled;
@property (readonly, copy) NSString *password;
@property (readonly, copy) NSString *path;
@property (readonly) NSNumber *preOrderReportsEnabled;
@property (readonly, copy) NSString *reportDir;
@property (readonly) NSNumber *salesReportsDisabled;
@property (readonly, copy) NSString *username;
@property (readonly, copy) NSString *vendorID;
@property (readonly, copy) NSString *vendorName;

- (id)initWithMonitor:(id <Monitor>)monitor
              andPath:(NSString *)vendorFile;

- (BOOL)isValid;

@end
