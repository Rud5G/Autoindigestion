#import "Tool.h"

#import "Autoingestion.h"
#import "AutoingestionJob.h"
#import "AutoingestionResponse.h"
#import "ConfigurationFile.h"
#import "Defaults.h"
#import "Group.h"
#import "Monitor.h"
#import "NSObject+Autoindigestion.h"
#import "NSString+Autoindigestion.h"
#import "Options.h"
#import "Vendor.h"
#import "VendorFile.h"
#import "User.h"


@implementation Tool


@synthesize autoingestion;
@synthesize fileMode;
@synthesize group;
@synthesize monitor;
@synthesize owner;
@synthesize reportRoot;
@synthesize vendors;


- (id)initWithMonitor:(id <Monitor>)theMonitor
             defaults:(Defaults *)defaults
    configurationFile:(ConfigurationFile *)configurationFile
           andOptions:(Options *)options;
{
  self = [super init];
  if ( ! self) return nil;

  monitor = theMonitor;
  vendors = [NSMutableArray array];

  autoingestion = [[Autoingestion alloc] initWithMonitor:monitor
                                                defaults:defaults
                                                 options:options
                                    andConfigurationFile:configurationFile];
  fileMode = [defaults fileMode];
  group = [NSObject firstValueForKey:kGroupKey
                         fromObjects:configurationFile, defaults, nil];
  owner = [NSObject firstValueForKey:kOwnerKey
                         fromObjects:configurationFile, defaults, nil];
  reportRoot = [defaults reportRoot];

  NSString *vendorsDir = [NSObject firstValueForKey:kVendorsDirKey
                                        fromObjects:options, configurationFile, defaults, nil];
  if ( ! [[NSFileManager defaultManager] fileExistsAtPath:vendorsDir]) {
    [monitor exitOnFailureWithFormat:@"Configuration directory \"%@\" not found",
             vendorsDir];
    return nil;
  }

  NSError *error;
  NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:vendorsDir
                                                                           error:&error];
  if ( ! filenames) {
    [monitor exitOnFailureWithError:error];
    return nil;
  }

  for (NSString *filename in filenames) {
    if ([filename hasSuffix:@".plist"]) {
      NSString *vendorFilePath = [vendorsDir stringByAppendingPathComponent:filename];
      VendorFile *vendorFile = [[VendorFile alloc] initWithMonitor:monitor
                                                           andPath:vendorFilePath];
      Vendor *vendor = [[Vendor alloc] initWithMonitor:monitor
                                              defaults:defaults
                                     configurationFile:configurationFile
                                         autoingestion:autoingestion
                                         andVendorFile:vendorFile];
      [vendors addObject:vendor];
    }
  }
  
  if ( ! [vendors count]) {
    [monitor warningWithFormat:@"No vendor files found in \"%@\"", vendorsDir];
  }

  NSPredicate *enabled = [NSPredicate predicateWithFormat:@"disabled = NO"];
  [vendors filterUsingPredicate:enabled];
  if ( ! [vendors count]) {
    [monitor warningWithFormat:@"No enabled vendor files found in \"%@\"", vendorsDir];
  }

  return self;
}


- (void)prepare;
{
  for (Vendor *vendor in vendors) {
    if ([reportRoot isParentOfPath:[vendor reportDir]]) {
      if ( ! [[NSFileManager defaultManager] fileExistsAtPath:reportRoot]) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     [owner ID], NSFileOwnerAccountID,
                                                     [group ID], NSFileGroupOwnerAccountID,
                                                     fileMode, NSFilePosixPermissions,
                                                     nil];
        NSError *error;
        BOOL created = [[NSFileManager defaultManager] createDirectoryAtPath:reportRoot
                                                 withIntermediateDirectories:YES
                                                                  attributes:attributes
                                                                       error:&error];
        if ( ! created) {
          [monitor exitOnFailureWithError:error];
        }
      }
    }

    [vendor prepare];
  }
}


- (void)downloadReports;
{
  NSMutableArray *autoingestionJobs = [NSMutableArray array];
  for (Vendor *vendor in vendors) {
    [autoingestionJobs addObjectsFromArray:[vendor autoingestionJobs]];
  }

  NSUInteger jobCount = 0;
  NSUInteger retryCount = 0;
  BOOL tryAgain;
  do {
    tryAgain = NO;
    for (AutoingestionJob *autoingestionJob in autoingestionJobs) {
      [autoingestionJob run];
      ++jobCount;
      
      if (   [[autoingestionJob response] isNetworkUnavailable]
          && 1 == jobCount
          && 0 == retryCount)
      {
        ++retryCount;
        tryAgain = YES;
        double waitForNetworkTimeout = 60.0;
        [monitor warningWithFormat:@"Can't reach iTunes Connect server: "
                                   @"sleeping for %.0f seconds and trying again",
                                   waitForNetworkTimeout];
        [NSThread sleepForTimeInterval:waitForNetworkTimeout];
        break;
      }
    }
  } while (tryAgain);
}


@end
