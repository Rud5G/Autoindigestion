#import "ReportCategory.h"

#import "Autoingestion.h"
#import "AutoingestionJob.h"
#import "Defaults.h"
#import "Group.h"
#import "Monitor.h"
#import "NSCalendar+Autoindigestion.h"
#import "NSDate+Autoindigestion.h"
#import "User.h"
#import "Vendor.h"


NSString *const kDateTypeDaily = @"Daily";
NSString *const kDateTypeWeekly = @"Weekly";
NSString *const kReportSubtypeOptIn = @"Opt-In";
NSString *const kReportSubtypeSummary = @"Summary";
NSString *const kReportTypePreOrder = @"Pre-Order";
NSString *const kReportTypeSales = @"Sales";


@implementation ReportCategory


@synthesize autoingestion;
@synthesize dateType;
@synthesize defaults;
@synthesize fileMode;
@synthesize group;
@synthesize monitor;
@synthesize owner;
@synthesize reportDir;
@synthesize reportSubtype;
@synthesize reportType;
@synthesize vendor;


- (NSArray *)autoingestionTasks;
{
  NSError *error;
  NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:reportDir
                                                                           error:&error];
  if ( ! filenames) {
    [monitor warningWithError:error];
    return [NSArray array];
  }

  // TODO: works for Sales Summary reports but is a guess for Opt-In and Pre-Order
  NSString *reportFilenamePattern = [NSString stringWithFormat:@"%@_(\\d{8})",
                                              [vendor vendorID]];
  NSRegularExpression *reportFilenameExpression = [NSRegularExpression regularExpressionWithPattern:reportFilenamePattern
                                                                                            options:0
                                                                                              error:&error];
  if ( ! reportFilenameExpression) {
    [monitor exitOnFailureWithError:error];
  }

  NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
    NSString *filename = evaluatedObject;
    NSRange range = NSMakeRange(0, [filename length]);
    NSTextCheckingResult *textCheckingResult = [reportFilenameExpression firstMatchInString:filename
                                                                                    options:0
                                                                                      range:range];
    return [textCheckingResult numberOfRanges] > 0;
  }];
  NSArray *reportFilenames = [filenames filteredArrayUsingPredicate:predicate];


  NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  NSCalendar *calendar = [locale objectForKey:NSLocaleCalendar];
  NSDate *today = [calendar zeroOutTimeForDate:[NSDate date]];


  NSDate *startingReportDate = nil;
  if ([self isDaily]) {
    // TODO: works for Sales Summary reports but is a guess for Pre-Order
    startingReportDate = [calendar twoWeeksAgoForDate:today];
  } else {
    // TODO: works for Sales Summary reports but is a guess for Opt-In and Pre-Order
    startingReportDate = [calendar thirteenSundaysAgoForDate:today];
  }

  if ([reportFilenames count]) {
    NSMutableArray *existingReportDates = [NSMutableArray array];
    for (NSString *reportFilename in reportFilenames) {
      NSRange range = NSMakeRange(0, [reportFilename length]);
      NSTextCheckingResult *textCheckingResult = [reportFilenameExpression firstMatchInString:reportFilename
                                                                                      options:0
                                                                                        range:range];
      if (NSNotFound == [textCheckingResult range].location) {
        [monitor warningWithFormat:@"Filename \"%@\" in \"%@\" didn't match",
                 reportFilename, reportDir];
      } else if ([textCheckingResult numberOfRanges] < 2) {
        [monitor warningWithFormat:@"Date part not found in filename \"%@\" in \"%@\"",
                 reportFilename, reportDir];
      } else {
        NSString *existingReportDate = [reportFilename substringWithRange:[textCheckingResult rangeAtIndex:1]];
        [existingReportDates addObject:existingReportDate];
      }
    }
    [existingReportDates sortUsingSelector:@selector(compare:)];

    NSDate *latestExistingReportDate = [calendar dateFromReportDate:[existingReportDates lastObject]];
    if ([latestExistingReportDate isLaterThanDate:startingReportDate]) {
      if ([self isDaily]) {
        startingReportDate = [calendar nextDayForDate:latestExistingReportDate];
      } else {
        startingReportDate = [calendar nextWeekForDate:latestExistingReportDate];
      }
    }
  }


  NSMutableArray *autoingestionTasks = [NSMutableArray array];
  NSDate *reportDate = startingReportDate;
  while ([reportDate isEarlierThanDate:today]) {
    AutoingestionJob *autoingestionTask = [[AutoingestionJob alloc] initWithMonitor:monitor
                                                                       reportCategory:self
                                                                        andReportDate:reportDate];
    [autoingestionTasks addObject:autoingestionTask];

    if ([self isDaily]) {
      reportDate = [calendar nextDayForDate:reportDate];
    } else {
      reportDate = [calendar nextWeekForDate:reportDate];
    }
  }

  return autoingestionTasks;
}


- (id)initWithMonitor:(id <Monitor>)theMonitor
             defaults:(Defaults *)theDefaults
        autoingestion:(Autoingestion *)theAutoingestion
               vendor:(Vendor *)theVendor
           reportType:(NSString *)theReportType
             dateType:(NSString *)theDateType
     andReportSubtype:(NSString *)theReportSubtype;
{
  self = [super init];
  if ( ! self) return nil;

  autoingestion = theAutoingestion;
  dateType = theDateType;
  defaults = theDefaults;
  monitor = theMonitor;
  reportSubtype = theReportSubtype;
  reportType = theReportType;
  vendor = theVendor;

  fileMode = [defaults fileMode];
  group = [vendor group];
  owner = [vendor owner];

  if (   [kReportTypeSales isEqualToString:reportType]
      && [kReportSubtypeOptIn isEqualToString:reportSubtype])
  {
    reportDir = [[vendor reportDir] stringByAppendingPathComponent:reportSubtype];
  } else {
    NSString *reportTypeDir = [[vendor reportDir] stringByAppendingPathComponent:reportType];
    reportDir = [reportTypeDir stringByAppendingPathComponent:dateType];
  }

  return self;
}


- (BOOL)isDaily;
{
  return [kDateTypeDaily isEqualToString:dateType];
}


- (BOOL)isWeekly;
{
  return [kDateTypeWeekly isEqualToString:dateType];
}


- (void)prepare;
{
  if ( ! [[NSFileManager defaultManager] fileExistsAtPath:reportDir]) {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [owner ID], NSFileOwnerAccountID,
                                                 [group ID], NSFileGroupOwnerAccountID,
                                                 fileMode, NSFilePosixPermissions,
                                                 nil];
    NSError *error;
    BOOL created = [[NSFileManager defaultManager] createDirectoryAtPath:reportDir
                                             withIntermediateDirectories:YES
                                                              attributes:attributes
                                                                   error:&error];
    if ( ! created) {
      [monitor exitOnFailureWithError:error];
    }
  }
}


@end
