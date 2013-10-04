#import "ReportDateType.h"

#import "NSCalendar+Autoindigestion.h"


static ReportDateType *daily;
static ReportDateType *monthly;
static ReportDateType *weekly;
static ReportDateType *yearly;


@interface ReportDateType ()

- (instancetype) initWithName:(NSString *)name
                dateFormatter:(NSDateFormatter *)dateFormatter
             dateStringLength:(int)dateStringLength
      nextReportDateAfterDate:(NSDate *(^)(NSDate *))nextReportDateAfterDate
andOldestReportDateBeforeDate:(NSDate *(^)(NSDate *))oldestReportDateBeforeDate;

@end


@implementation ReportDateType
{
  NSDate *(^_nextReportDateAfterDate)(NSDate *);
  NSDate *(^_oldestReportDateBeforeDate)(NSDate *);
  NSDateFormatter *_dateFormatter;
}


+ (instancetype)daily;
{
  return daily;
}


- (NSString *)formattedDateForDate:(NSDate *)date;
{
  return [_dateFormatter stringFromDate:date];
}


+ (void)initialize;
{
  if ([ReportDateType class] == self) {
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSDateFormatter *normalDateFormatter = [[NSDateFormatter alloc] init];
    [normalDateFormatter setLocale:locale];
    [normalDateFormatter setDateFormat:@"dd-MMM-yyyy"];

    daily = [[ReportDateType alloc] initWithName:@"Daily"
                                   dateFormatter:normalDateFormatter
                                dateStringLength:8
                         nextReportDateAfterDate:^(NSDate *date) {
                                                   return [[NSCalendar POSIXCalendar] nextDayForDate:date];
                                                 }
                   andOldestReportDateBeforeDate:^(NSDate *date) {
                                                   return [[NSCalendar POSIXCalendar] twoWeeksAgoForDate:date];
                                                 }
    ];

    weekly = [[ReportDateType alloc] initWithName:@"Weekly"
                                    dateFormatter:normalDateFormatter
                                 dateStringLength:8
                          nextReportDateAfterDate:^(NSDate *date) {
                                                    return [[NSCalendar POSIXCalendar] nextWeekForDate:date];
                                                  }
                    andOldestReportDateBeforeDate:^(NSDate *date) {
                                                    return [[NSCalendar POSIXCalendar] thirteenSundaysAgoForDate:date];
                                                  }
    ];

    NSDateFormatter *monthlyDateFormatter = [[NSDateFormatter alloc] init];
    [monthlyDateFormatter setLocale:locale];
    [monthlyDateFormatter setDateFormat:@"MMM-yyyy"];

    monthly = [[ReportDateType alloc] initWithName:@"Monthly"
                                     dateFormatter:monthlyDateFormatter
                                  dateStringLength:6
                           nextReportDateAfterDate:^(NSDate *date) {
                                                     return [[NSCalendar POSIXCalendar] nextMonthForDate:date];
                                                   }
                     andOldestReportDateBeforeDate:^(NSDate *date) {
                                                     return [[NSCalendar POSIXCalendar] twelveFirstOfTheMonthsAgoForDate:date];
                                                   }
    ];

    NSDateFormatter *yearlyDateFormatter = [[NSDateFormatter alloc] init];
    [yearlyDateFormatter setLocale:locale];
    [yearlyDateFormatter setDateFormat:@"yyyy"];

    yearly = [[ReportDateType alloc] initWithName:@"Yearly"
                                    dateFormatter:yearlyDateFormatter
                                 dateStringLength:4
                          nextReportDateAfterDate:^(NSDate *date) {
                                                    return [[NSCalendar POSIXCalendar] nextYearForDate:date];
                                                  }
                    andOldestReportDateBeforeDate:^(NSDate *date) {
                                                    return [[NSCalendar POSIXCalendar] fiveNewYearsDaysAgoForDate:date];
                                                  }
    ];
  }
}


- (instancetype)init;
{
  [NSException raise:@"Not Implemented" format:@"%s", __FUNCTION__];
  return nil;
}


- (instancetype) initWithName:(NSString *)name
                 dateFormatter:(NSDateFormatter *)dateFormatter
                 dateStringLength:(int)dateStringLength
      nextReportDateAfterDate:(NSDate *(^)(NSDate *))nextReportDateAfterDate
andOldestReportDateBeforeDate:(NSDate *(^)(NSDate *))oldestReportDateBeforeDate;
{
  self = [super init];
  if ( ! self) return nil;

  _dateFormatter = dateFormatter;
  _dateStringLength = dateStringLength;
  _name = [name copy];
  _nextReportDateAfterDate = nextReportDateAfterDate;
  _oldestReportDateBeforeDate = oldestReportDateBeforeDate;

  _codeLetter = [[_name substringToIndex:1] copy];
  
  return self;
}


+ (instancetype)monthly;
{
  return monthly;
}


- (NSDate *)nextReportDateAfterDate:(NSDate *)date;
{
  return _nextReportDateAfterDate(date);
}


- (NSDate *)oldestReportDateBeforeDate:(NSDate *)date;
{
  return _oldestReportDateBeforeDate(date);
}


+ (instancetype)weekly;
{
  return weekly;
}


+ (instancetype)yearly;
{
  return yearly;
}


@end
