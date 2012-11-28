#import <SenTestingKit/SenTestingKit.h>
#import "User.h"

#import "Group.h"


@interface UserTest : SenTestCase
@end


@implementation UserTest


- (void)testEffectiveUserWithError;
{
  NSError *error = nil;
  User *user = [User effectiveUserWithError:&error];
  
  STAssertNotNil(user, nil);
  STAssertNil(error, nil);
}


- (void)testInitWithIDError;
{
  NSError *error = nil;
  User *user = [[User alloc] initWithID:@0 error:&error];
  
  STAssertNotNil(user, nil);
  STAssertNil(error, nil);
  
  STAssertEqualObjects(@"root", [user description], nil);
  STAssertEqualObjects(@"/var/root", [user directory], nil);
  STAssertEqualObjects(@"System Administrator", [user fullName], nil);
  STAssertEquals(0u, [user GID], nil);
  STAssertEqualObjects(@0, [user ID], nil);
  STAssertEqualObjects(@"root", [user name], nil);
  STAssertEqualObjects(@"*", [user password], nil);
  STAssertEqualObjects(@0, [user primaryGroupID], nil);
  STAssertEqualObjects(@"/bin/sh", [user shell], nil);
  STAssertEquals(0u, [user UID], nil);
  
  Group *group = [user primaryGroupWithError:&error];
  
  STAssertNotNil(group, nil);
  STAssertNil(error, nil);
  
  STAssertEqualObjects(@"wheel", [group description], nil);
  STAssertEquals(0u, [group GID], nil);
}


- (void)testInitWithNameError;
{
  NSError *error = nil;
  User *user = [[User alloc] initWithName:@"root" error:&error];
  
  STAssertNotNil(user, nil);
  STAssertNil(error, nil);
  
  STAssertEqualObjects(@"root", [user description], nil);
  STAssertEqualObjects(@"/var/root", [user directory], nil);
  STAssertEqualObjects(@"System Administrator", [user fullName], nil);
  STAssertEquals(0u, [user GID], nil);
  STAssertEqualObjects(@0, [user ID], nil);
  STAssertEqualObjects(@"root", [user name], nil);
  STAssertEqualObjects(@"*", [user password], nil);
  STAssertEqualObjects(@0, [user primaryGroupID], nil);
  STAssertEqualObjects(@"/bin/sh", [user shell], nil);
  STAssertEquals(0u, [user UID], nil);
}


- (void)testInitWithPasswd;
{
  struct passwd posixUser = {
    .pw_name = "someone",
    .pw_passwd = "password",
    .pw_uid = 42,
    .pw_gid = 43,
    .pw_change = 1001,
    .pw_class = "class",
    .pw_gecos = "Some One",
    .pw_dir = "/Users/someone",
    .pw_shell = "/bin/bash",
    .pw_expire = 2002,
  };
  
  User *user = [[User alloc] initWithPasswd:&posixUser];
  
  STAssertEqualObjects(@"someone", [user description], nil);
  STAssertEqualObjects(@"/Users/someone", [user directory], nil);
  STAssertEqualObjects(@"Some One", [user fullName], nil);
  STAssertEquals(43u, [user GID], nil);
  STAssertEqualObjects(@42, [user ID], nil);
  STAssertEqualObjects(@"someone", [user name], nil);
  STAssertEqualObjects(@"password", [user password], nil);
  STAssertEqualObjects(@43, [user primaryGroupID], nil);
  STAssertEqualObjects(@"/bin/bash", [user shell], nil);
  STAssertEquals(42u, [user UID], nil);
}


- (void)testInitWithPasswd_makes_deep_copy;
{
  struct passwd posixUser = {
    .pw_name = "someone",
    .pw_passwd = "password",
    .pw_uid = 42,
    .pw_gid = 43,
    .pw_change = 1001,
    .pw_class = "class",
    .pw_gecos = "Some One",
    .pw_dir = "/Users/someone",
    .pw_shell = "/bin/bash",
    .pw_expire = 2002,
  };
  
  User *user = [[User alloc] initWithPasswd:&posixUser];
  
  STAssertTrue(posixUser.pw_name != [user passwd].pw_name, nil);
  STAssertTrue(posixUser.pw_passwd != [user passwd].pw_passwd, nil);
  STAssertTrue(posixUser.pw_class != [user passwd].pw_class, nil);
  STAssertTrue(posixUser.pw_gecos != [user passwd].pw_gecos, nil);
  STAssertTrue(posixUser.pw_dir != [user passwd].pw_dir, nil);
  STAssertTrue(posixUser.pw_shell != [user passwd].pw_shell, nil);
}


- (void)testInitWithPasswd_with_nulls;
{
  struct passwd posixUser = {
    .pw_name = NULL,
    .pw_passwd = NULL,
    .pw_uid = 42,
    .pw_gid = 43,
    .pw_change = 1001,
    .pw_class = NULL,
    .pw_gecos = NULL,
    .pw_dir = NULL,
    .pw_shell = NULL,
    .pw_expire = 2002,
  };
  
  User *user = [[User alloc] initWithPasswd:&posixUser];
  
  STAssertEqualObjects(@"(NULL)", [user description], nil);
  STAssertNil([user directory], nil);
  STAssertNil([user fullName], nil);
  STAssertNil([user name], nil);
  STAssertNil([user password], nil);
  STAssertNil([user shell], nil);
}


- (void)testInitWithUIDError;
{
  NSError *error = nil;
  User *user = [[User alloc] initWithUID:0 error:&error];
  
  STAssertNotNil(user, nil);
  STAssertNil(error, nil);
  
  STAssertEqualObjects(@"root", [user description], nil);
  STAssertEqualObjects(@"/var/root", [user directory], nil);
  STAssertEqualObjects(@"System Administrator", [user fullName], nil);
  STAssertEquals(0u, [user GID], nil);
  STAssertEqualObjects(@0, [user ID], nil);
  STAssertEqualObjects(@"root", [user name], nil);
  STAssertEqualObjects(@"*", [user password], nil);
  STAssertEqualObjects(@0, [user primaryGroupID], nil);
  STAssertEqualObjects(@"/bin/sh", [user shell], nil);
  STAssertEquals(0u, [user UID], nil);
}


- (void)testInitWithUsernameError;
{
  NSError *error = nil;
  User *user = [[User alloc] initWithUsername:"root" error:&error];
  
  STAssertNotNil(user, nil);
  STAssertNil(error, nil);
  
  STAssertEqualObjects(@"root", [user description], nil);
  STAssertEqualObjects(@"/var/root", [user directory], nil);
  STAssertEqualObjects(@"System Administrator", [user fullName], nil);
  STAssertEquals(0u, [user GID], nil);
  STAssertEqualObjects(@0, [user ID], nil);
  STAssertEqualObjects(@"root", [user name], nil);
  STAssertEqualObjects(@"*", [user password], nil);
  STAssertEqualObjects(@0, [user primaryGroupID], nil);
  STAssertEqualObjects(@"/bin/sh", [user shell], nil);
  STAssertEquals(0u, [user UID], nil);
}


- (void)testRealUserWithError;
{
  NSError *error = nil;
  User *user = [User realUserWithError:&error];
  
  STAssertNotNil(user, nil);
  STAssertNil(error, nil);
}


@end
