#import "Group.h"

#import "NSError+Autoindigestion.h"
#import "User.h"


@implementation Group


@synthesize group;


- (NSString *)description;
{
  return [self name];
}


+ (Group *)effectiveGroupWithError:(NSError **)error;
{
  return [[self alloc] initWithGID:getegid() error:error];
}


- (gid_t)GID;
{
  return group.gr_gid;
}


- (char const *)groupName;
{
  return group.gr_name;
}


- (NSNumber *)ID;
{
  return [NSNumber numberWithUnsignedLong:group.gr_gid];
}


- (id)init;
{
  [NSException raise:@"Not Implemented" format:@"%s", __FUNCTION__];
  return nil;
}


- (id)initWithGID:(gid_t)GID
            error:(NSError **)error;
{
  errno = 0;
  struct group *theGroup = getgrgid(GID);
  if (theGroup) return [self initWithGroup:theGroup];

  if (error) {
    *error = errno ? [NSError currentPOSIXError] : nil;
  }
  return nil;
}


- (id)initWithGroup:(struct group *)theGroup;
{
  self = [super init];
  if ( ! self) return nil;

  memcpy(&group, theGroup, sizeof(struct group));

  return self;
}


- (id)initWithName:(NSString *)name
             error:(NSError **)error;
{
  char const *groupName = [name UTF8String];
  errno = 0;
  struct group *theGroup = getgrnam(groupName);
  if (theGroup) return [self initWithGroup:theGroup];

  if (error) {
    *error = errno ? [NSError currentPOSIXError] : nil;
  }
  return nil;
}


- (NSArray *)memberNames;
{
  NSMutableArray *members = [NSMutableArray array];
  char **groupMember = group.gr_mem;
  while (*groupMember) {
    NSString *member = [NSString stringWithCString:*groupMember
                                          encoding:NSUTF8StringEncoding];
    [members addObject:member];
    ++groupMember;
  }
  return [members copy];
}


- (NSArray *)membersWithError:(NSError **)error;
{
  NSMutableArray *members = [NSMutableArray array];
  char **groupMember = group.gr_mem;
  while (*groupMember) {
    User *member = [[User alloc] initWithUsername:*groupMember error:error];
    if ( ! member) return nil;
    [members addObject:member];
    ++groupMember;
  }
  return [members copy];
}


- (NSString *)name;
{
  return [NSString stringWithCString:group.gr_name
                            encoding:NSUTF8StringEncoding];
}


+ (Group *)realGroupWithError:(NSError **)error;
{
  return [[self alloc] initWithGID:getgid() error:error];
}


@end
