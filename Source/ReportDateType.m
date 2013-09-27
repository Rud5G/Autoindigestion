#import "ReportDateType.h"


static ReportDateType *daily;
static ReportDateType *weekly;
static ReportDateType *yearly;


@interface ReportDateType ()

- (instancetype)initWithName:(NSString *)name;

@end


@implementation ReportDateType


+ (instancetype)daily;
{
  return daily;
}


+ (void)initialize;
{
  if ([ReportDateType class] == self) {
    daily = [[ReportDateType alloc] initWithName:@"Daily"];
    weekly = [[ReportDateType alloc] initWithName:@"Weekly"];
    yearly = [[ReportDateType alloc] initWithName:@"Yearly"];
  }
}


- (instancetype)initWithName:(NSString *)name;
{
  self = [super init];
  if ( ! self) return nil;
  
  _name = [name copy];

  _codeLetter = [[_name substringToIndex:1] copy];
  
  return self;
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
