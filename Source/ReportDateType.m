#import "ReportDateType.h"

#import "NSCalendar+Autoindigestion.h"


static ReportDateType *daily;
static ReportDateType *weekly;
static ReportDateType *yearly;


@interface ReportDateType ()

- (instancetype) initWithName:(NSString *)name
andOldestReportDateBeforeDate:(NSDate *(^)(NSDate *))oldestReportDateBeforeDate;

@end


@implementation ReportDateType
{
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
                   andOldestReportDateBeforeDate:^(NSDate *date) {
                     return [[NSCalendar POSIXCalendar] twoWeeksAgoForDate:date];
                   }];

    weekly = [[ReportDateType alloc] initWithName:@"Weekly"
                    andOldestReportDateBeforeDate:^(NSDate *date) {
                      return [[NSCalendar POSIXCalendar] thirteenSundaysAgoForDate:date];
                    }];

    yearly = [[ReportDateType alloc] initWithName:@"Yearly"
                    andOldestReportDateBeforeDate:^(NSDate *date) {
                      return [[NSCalendar POSIXCalendar] fiveNewYearsDaysAgoForDate:date];
                    }];
  }
}


- (instancetype) initWithName:(NSString *)name
andOldestReportDateBeforeDate:(NSDate *(^)(NSDate *))oldestReportDateBeforeDate;
{
  self = [super init];
  if ( ! self) return nil;
  
  _name = [name copy];
  _oldestReportDateBeforeDate = oldestReportDateBeforeDate;

  _codeLetter = [[_name substringToIndex:1] copy];
  
  return self;
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
