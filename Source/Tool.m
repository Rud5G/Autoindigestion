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


- (void)cleanUp;
{
  for (Vendor *vendor in _vendors) {
    [vendor cleanUp];
  }
}


- (id)init;
{
  [NSException raise:@"Not Implemented" format:@"%s", __FUNCTION__];
  return nil;
}


- (id)initWithMonitor:(id <Monitor>)theMonitor
             defaults:(Defaults *)defaults
    configurationFile:(ConfigurationFile *)configurationFile
           andOptions:(Options *)options;
{
  self = [super init];
  if ( ! self) return nil;

  _monitor = theMonitor;
  _vendors = [NSMutableArray array];

  _autoingestion = [[Autoingestion alloc] initWithMonitor:_monitor
                                                 defaults:defaults
                                                  options:options
                                     andConfigurationFile:configurationFile];
  _fileMode = [defaults fileMode];
  _group = [NSObject firstValueForKey:kGroupKey
                          fromObjects:configurationFile, defaults, nil];
  _owner = [NSObject firstValueForKey:kOwnerKey
                          fromObjects:configurationFile, defaults, nil];
  _reportRoot = [[defaults reportRoot] copy];

  NSString *vendorsDir = [NSObject firstValueForKey:kVendorsDirKey
                                        fromObjects:options, configurationFile, defaults, nil];
  if ( ! [[NSFileManager defaultManager] fileExistsAtPath:vendorsDir]) {
    [_monitor exitOnFailureWithFormat:@"Configuration directory \"%@\" not found",
              vendorsDir];
    return nil;
  }

  NSError *error;
  NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:vendorsDir
                                                                           error:&error];
  if ( ! filenames) {
    [_monitor exitOnFailureWithError:error];
    return nil;
  }

  for (NSString *filename in filenames) {
    if ([filename hasSuffix:@".plist"]) {
      NSString *vendorFilePath = [vendorsDir stringByAppendingPathComponent:filename];
      VendorFile *vendorFile = [[VendorFile alloc] initWithMonitor:_monitor
                                                           andPath:vendorFilePath];
      Vendor *vendor = [[Vendor alloc] initWithMonitor:_monitor
                                              defaults:defaults
                                     configurationFile:configurationFile
                                         autoingestion:_autoingestion
                                         andVendorFile:vendorFile];
      [_vendors addObject:vendor];
    }
  }
  
  if ( ! [_vendors count]) {
    [_monitor warningWithFormat:@"No vendor files found in \"%@\"", vendorsDir];
  }

  NSPredicate *enabled = [NSPredicate predicateWithFormat:@"disabled = NO"];
  [_vendors filterUsingPredicate:enabled];
  if ( ! [_vendors count]) {
    [_monitor warningWithFormat:@"No enabled vendor files found in \"%@\"", vendorsDir];
  }

  return self;
}


- (void)prepare;
{
  for (Vendor *vendor in _vendors) {
    if ([_reportRoot isParentOfPath:[vendor reportDir]]) {
      if ( ! [[NSFileManager defaultManager] fileExistsAtPath:_reportRoot]) {
        NSDictionary *attributes = @{
            NSFileOwnerAccountID : [_owner ID],
            NSFileGroupOwnerAccountID : [_group ID],
            NSFilePosixPermissions : _fileMode,
        };
        NSError *error;
        BOOL created = [[NSFileManager defaultManager] createDirectoryAtPath:_reportRoot
                                                 withIntermediateDirectories:YES
                                                                  attributes:attributes
                                                                       error:&error];
        if ( ! created) {
          [_monitor exitOnFailureWithError:error];
        }
      }
    }

    [vendor prepare];
  }
}


- (void)downloadReports;
{
  NSMutableArray *autoingestionJobs = [NSMutableArray array];
  for (Vendor *vendor in _vendors) {
    [autoingestionJobs addObjectsFromArray:[vendor autoingestionJobs]];
  }

  NSUInteger jobCount = 0;
  NSUInteger retryCount = 0;
  BOOL tryAgainNow;
  do {
    tryAgainNow = NO;
    for (AutoingestionJob *autoingestionJob in autoingestionJobs) {
      [autoingestionJob run];
      ++jobCount;
      
      if (   [[autoingestionJob response] isNetworkUnavailable]
          && 1 == jobCount
          && 0 == retryCount)
      {
        ++retryCount;
        tryAgainNow = YES;
        double waitForNetworkTimeout = 60.0;
        [_monitor warningWithFormat:@"Can't reach iTunes Connect server: "
                                    @"sleeping for %.0f seconds and trying again",
                                    waitForNetworkTimeout];
        [NSThread sleepForTimeInterval:waitForNetworkTimeout];
        break;
      }
      if ([[autoingestionJob response] isTryAgainLater]) {
        [_monitor warningWithFormat:@"Download stopped: iTunes Connect reports not available yet"];
        tryAgainNow = NO;
        break;
      }
    }
  } while (tryAgainNow);
}


@end
