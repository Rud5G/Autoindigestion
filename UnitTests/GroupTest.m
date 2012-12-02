#import <SenTestingKit/SenTestingKit.h>
#import "Group.h"
#import "User.h"


@interface GroupTest : SenTestCase
@end


@implementation GroupTest


- (void)testEffectiveGroupWithError;
{
  NSError *error = nil;
  Group *group = [Group effectiveGroupWithError:&error];
  
  STAssertNotNil(group, nil);
  STAssertNil(error, nil);
}


- (void)testInitWithGIDError;
{
  NSError *error = nil;
  Group *group = [[Group alloc] initWithGID:0 error:&error];
  
  STAssertNotNil(group, nil);
  STAssertNil(error, nil);
  
  STAssertEqualObjects(@"wheel", [group description], nil);
  STAssertEquals(0u, [group GID], nil);
  STAssertEqualObjects(@0, [group ID], nil);
  STAssertEqualObjects(@"wheel", [group name], nil);
  
  NSArray *memberNames = [group memberNames];
  STAssertTrue([memberNames count] > 0, nil);
  STAssertTrue([memberNames indexOfObject:@"root"] != NSNotFound, nil);
  
  NSArray *members = [group membersWithError:&error];
  STAssertTrue([members count] > 0, nil);
  
  NSPredicate *rootUser = [NSPredicate predicateWithFormat:@"name = 'root'"];
  NSArray *root = [members filteredArrayUsingPredicate:rootUser];
  STAssertEquals(1lu, [root count], nil);
}


- (void)testInitWithGroup;
{
  char *groupMembers[] = {
    "me", "you", "someone", NULL,
  };
  
  struct group posixGroup = {
    .gr_name = "test",
    .gr_passwd = "*",
    .gr_gid = 42,
    .gr_mem = groupMembers,
  };
  
  Group *group = [[Group alloc] initWithGroup:&posixGroup];
  
  STAssertEqualObjects(@"test", [group description], nil);
  STAssertEquals(42u, [group GID], nil);
  STAssertEqualObjects(@42, [group ID], nil);
  STAssertEqualObjects(@"test", [group name], nil);
  
  NSArray *memberNames = [group memberNames];
  STAssertEquals(3ul, [memberNames count], nil);
  STAssertEqualObjects(@"me", memberNames[0], nil);
  STAssertEqualObjects(@"you", memberNames[1], nil);
  STAssertEqualObjects(@"someone", memberNames[2], nil);
}


- (void)testInitWithGroup_makes_deep_copy;
{
  char *groupMembers[] = {
    "me", "you", "someone", NULL,
  };
  
  struct group posixGroup = {
    .gr_name = "test",
    .gr_passwd = "*",
    .gr_gid = 42,
    .gr_mem = groupMembers,
  };
  
  Group *group = [[Group alloc] initWithGroup:&posixGroup];
  
  STAssertTrue(posixGroup.gr_name != [group group].gr_name, nil);
  STAssertTrue(posixGroup.gr_passwd != [group group].gr_passwd, nil);
  STAssertTrue(posixGroup.gr_mem != [group group].gr_mem, nil);
  STAssertTrue(posixGroup.gr_mem[0] != [group group].gr_mem[0], nil);
  STAssertTrue(posixGroup.gr_mem[1] != [group group].gr_mem[1], nil);
  STAssertTrue(posixGroup.gr_mem[2] != [group group].gr_mem[2], nil);
  STAssertEquals((char *) NULL, [group group].gr_mem[3], nil);
}


- (void)testInitWithGroup_with_no_members;
{
  char *groupMembers[] = {
    NULL,
  };
  
  struct group posixGroup = {
    .gr_name = "test",
    .gr_passwd = NULL,
    .gr_gid = 42,
    .gr_mem = groupMembers,
  };
  
  Group *group = [[Group alloc] initWithGroup:&posixGroup];
  
  NSArray *memberNames = [group memberNames];
  STAssertEquals(0ul, [memberNames count], nil);
  
  NSError *error = nil;
  NSArray *members = [group membersWithError:&error];
  STAssertEquals(0ul, [members count], nil);
}


- (void)testInitWithGroup_with_nulls;
{
  struct group posixGroup = {
    .gr_name = NULL,
    .gr_passwd = NULL,
    .gr_gid = 42,
    .gr_mem = NULL,
  };
  
  Group *group = [[Group alloc] initWithGroup:&posixGroup];
  
  STAssertEqualObjects(@"(NULL)", [group description], nil);
  STAssertNil([group name], nil);
  
  NSArray *memberNames = [group memberNames];
  STAssertEquals(0ul, [memberNames count], nil);
  
  NSError *error = nil;
  NSArray *members = [group membersWithError:&error];
  STAssertEquals(0ul, [members count], nil);
}


- (void)testInitWithNameError;
{
  NSError *error = nil;
  Group *group = [[Group alloc] initWithName:@"wheel" error:&error];
  
  STAssertNotNil(group, nil);
  STAssertNil(error, nil);
  
  STAssertEqualObjects(@"wheel", [group description], nil);
  STAssertEquals(0u, [group GID], nil);
  STAssertEqualObjects(@0, [group ID], nil);
  STAssertEqualObjects(@"wheel", [group name], nil);
  
  NSArray *memberNames = [group memberNames];
  STAssertTrue([memberNames count] > 0, nil);
  STAssertTrue([memberNames indexOfObject:@"root"] != NSNotFound, nil);
  
  NSArray *members = [group membersWithError:&error];
  STAssertTrue([members count] > 0, nil);
  
  NSPredicate *rootUser = [NSPredicate predicateWithFormat:@"name = 'root'"];
  NSArray *root = [members filteredArrayUsingPredicate:rootUser];
  STAssertEquals(1lu, [root count], nil);
}


- (void)testInitWithNameError_with_multiple_members;
{
  NSError *error = nil;
  Group *group = [[Group alloc] initWithName:@"certusers" error:&error];
  
  if ( ! group && ! error) {
    NSLog(@"WARNING: skipping %s due to missing group \"certusers\"", __FUNCTION__);
    return;
  }
  
  STAssertNotNil(group, nil);
  STAssertNil(error, nil);
  
  STAssertEqualObjects(@"certusers", [group name], nil);
  
  NSArray *memberNames = [group memberNames];
  STAssertTrue([memberNames count] > 0, nil);
  STAssertTrue([memberNames indexOfObject:@"root"] != NSNotFound, nil);
  
  NSArray *members = [group membersWithError:&error];
  STAssertTrue([members count] > 0, nil);
  
  NSPredicate *rootUser = [NSPredicate predicateWithFormat:@"name = 'root'"];
  NSArray *root = [members filteredArrayUsingPredicate:rootUser];
  STAssertEquals(1lu, [root count], nil);
}


- (void)testRealGroupWithError;
{
  NSError *error = nil;
  Group *group = [Group realGroupWithError:&error];
  
  STAssertNotNil(group, nil);
  STAssertNil(error, nil);
}


@end
