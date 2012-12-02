#import "Group.h"

#import "NSError+Autoindigestion.h"
#import "User.h"


static char **duplicateNullTerminatedArrayOfStrings(char **arrayOfStrings);
static void freeGroupMemory(struct group *group);
static void freeNullTerminatedArrayOfStrings(char **arrayOfStrings);


@implementation Group


- (void)dealloc;
{
  freeGroupMemory(&_group);
}


- (NSString *)description;
{
  return _group.gr_name ? [self name] : @"(NULL)";
}


+ (Group *)effectiveGroupWithError:(NSError **)error;
{
  return [[self alloc] initWithGID:getegid() error:error];
}


- (gid_t)GID;
{
  return _group.gr_gid;
}


- (NSNumber *)ID;
{
  return @(_group.gr_gid);
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
  
  _group.gr_gid = theGroup->gr_gid;
  
  if (theGroup->gr_name) {
    _group.gr_name = strdup(theGroup->gr_name);
    if ( ! _group.gr_name) return nil;
  }
  
  if (theGroup->gr_passwd) {
    _group.gr_passwd = strdup(theGroup->gr_passwd);
    if ( ! _group.gr_passwd) {
      freeGroupMemory(&_group);
      return nil;
    }
  }
  
  if (theGroup->gr_mem) {
    _group.gr_mem = duplicateNullTerminatedArrayOfStrings(theGroup->gr_mem);
    if ( ! _group.gr_mem) {
      freeGroupMemory(&_group);
      return nil;
    }
  }
  
  return self;
}


- (id)initWithGroupName:(char const *)groupName
                  error:(NSError **)error;
{
  errno = 0;
  struct group *theGroup = getgrnam(groupName);
  if (theGroup) return [self initWithGroup:theGroup];
  
  if (error) {
    *error = errno ? [NSError currentPOSIXError] : nil;
  }
  return nil;
}


- (id)initWithID:(NSNumber *)ID
           error:(NSError **)error;
{
  gid_t GID = [ID unsignedIntValue];
  return [self initWithGID:GID error:error];
}


- (id)initWithName:(NSString *)name
             error:(NSError **)error;
{
  char const *groupName = [name UTF8String];
  return [self initWithGroupName:groupName error:error];
}


- (NSArray *)memberNames;
{
  NSMutableArray *memberNames = [NSMutableArray array];
  if (_group.gr_mem) {
    char **groupMember = _group.gr_mem;
    while (*groupMember) {
      NSString *memberName = [NSString stringWithCString:*groupMember
                                                encoding:NSUTF8StringEncoding];
      [memberNames addObject:memberName];
      ++groupMember;
    }
  }
  return [memberNames copy];
}


- (NSArray *)membersWithError:(NSError **)error;
{
  NSMutableArray *members = [NSMutableArray array];
  if (_group.gr_mem) {
    char **groupMember = _group.gr_mem;
    while (*groupMember) {
      User *member = [[User alloc] initWithUsername:*groupMember error:error];
      if ( ! member) return nil;
      [members addObject:member];
      ++groupMember;
    }
  }
  return [members copy];
}


- (NSString *)name;
{
  if (_group.gr_name) {
    return [NSString stringWithCString:_group.gr_name
                              encoding:NSUTF8StringEncoding];
  } else {
    return nil;
  }
}


+ (Group *)realGroupWithError:(NSError **)error;
{
  return [[self alloc] initWithGID:getgid() error:error];
}


@end


static char **duplicateNullTerminatedArrayOfStrings(char **arrayOfStrings)
{
  size_t stringCount = 0;
  char **strings = arrayOfStrings;
  while (*strings) {
    ++stringCount;
    ++strings;
  }
  
  size_t itemCount = stringCount + 1;
  char **duplicateArray = calloc(itemCount, sizeof(char *));
  if ( ! duplicateArray) return NULL;
  
  strings = arrayOfStrings;
  char **duplicateStrings = duplicateArray;
  while (*strings) {
    *duplicateStrings = strdup(*strings);
    if ( ! *duplicateStrings) {
      freeNullTerminatedArrayOfStrings(duplicateArray);
      return NULL;
    }
    ++strings;
    ++duplicateStrings;
  }
  
  return duplicateArray;
}


static void freeGroupMemory(struct group *group)
{
  freeNullTerminatedArrayOfStrings(group->gr_mem);
  free(group->gr_passwd);
  free(group->gr_name);
}


static void freeNullTerminatedArrayOfStrings(char **arrayOfStrings)
{
  if ( ! arrayOfStrings) return;
  
  char **strings = arrayOfStrings;
  while (*strings) {
    free(*strings);
    ++strings;
  }
  free(arrayOfStrings);
}
