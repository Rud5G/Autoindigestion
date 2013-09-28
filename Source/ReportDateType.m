#import "ReportDateType.h"

#import "NSCalendar+Autoindigestion.h"


static ReportDateType *daily;
static ReportDateType *weekly;
static ReportDateType *yearly;


@interface ReportDateType ()

- (instancetype) initWithName:(NSString *)name
      nextReportDateAfterDate:(NSDate *(^)(NSDate *))nextReportDateAfterDate
andOldestReportDateBeforeDate:(NSDate *(^)(NSDate *))oldestReportDateBeforeDate;

@end


@implementation ReportDateType
{
  NSDate *(^_nextReportDateAfterDate)(NSDate *);
  NSDate *(^_oldestReportDateBeforeDate)(NSDate *);
}


+ (instancetype)daily;
{
  return daily;
}


+ (void)initialize;
{
  if ([ReportDateType class] == self) {
    daily = [[ReportDateType alloc] initWithName:@"Daily"
                         nextReportDateAfterDate:^(NSDate *date) {
                                                   return [[NSCalendar POSIXCalendar] nextDayForDate:date];
                                                 }
                   andOldestReportDateBeforeDate:^(NSDate *date) {
                                                   return [[NSCalendar POSIXCalendar] twoWeeksAgoForDate:date];
                                                 }
    ];

    weekly = [[ReportDateType alloc] initWithName:@"Weekly"
                          nextReportDateAfterDate:^(NSDate *date) {
                                                    return [[NSCalendar POSIXCalendar] nextWeekForDate:date];
                                                  }
                    andOldestReportDateBeforeDate:^(NSDate *date) {
                                                    return [[NSCalendar POSIXCalendar] thirteenSundaysAgoForDate:date];
                                                  }
    ];

    yearly = [[ReportDateType alloc] initWithName:@"Yearly"
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
      nextReportDateAfterDate:(NSDate *(^)(NSDate *))nextReportDateAfterDate
andOldestReportDateBeforeDate:(NSDate *(^)(NSDate *))oldestReportDateBeforeDate;
{
  self = [super init];
  if ( ! self) return nil;
  
  _name = [name copy];
  _nextReportDateAfterDate = nextReportDateAfterDate;
  _oldestReportDateBeforeDate = oldestReportDateBeforeDate;

  _codeLetter = [[_name substringToIndex:1] copy];
  
  return self;
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
