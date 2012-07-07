#import <pwd.h>
#import "User.h"

#import "Group.h"
#import "NSError+Autoindigestion.h"


@implementation User


@synthesize passwd;


- (NSString *)description;
{
  return [self name];
}


- (NSString *)directory;
{
  return [NSString stringWithCString:passwd.pw_dir
                            encoding:NSUTF8StringEncoding];
}


+ (User *)effectiveUserWithError:(NSError **)error;
{
  return [[self alloc] initWithUID:geteuid() error:error];
}


- (NSNumber *)ID;
{
  return [NSNumber numberWithUnsignedLong:passwd.pw_gid];
}


- (id)init;
{
  [NSException raise:@"Not Implemented" format:@"%s", __FUNCTION__];
  return nil;
}


- (id)initWithID:(NSNumber *)ID
           error:(NSError **)error;
{
  uid_t UID = [ID unsignedLongValue];
  return [self initWithUID:UID error:error];
}


- (id)initWithName:(NSString *)name
             error:(NSError **)error;
{
  return [self initWithUsername:[name UTF8String] error:error];
}


- (id)initWithPasswd:(struct passwd *)thePasswd;
{
  self = [super init];
  if ( ! self) return nil;

  passwd = *thePasswd;
  memcpy(&passwd, thePasswd, sizeof(struct passwd));

  return self;
}


- (id)initWithUID:(uid_t)UID
            error:(NSError **)error;
{
  errno = 0;
  struct passwd *thePasswd = getpwuid(UID);
  if (thePasswd) return [self initWithPasswd:thePasswd];

  if (error) {
    *error = errno ? [NSError currentPOSIXError] : nil;
  }
  return nil;
}


- (id)initWithUsername:(char const *)username
                 error:(NSError **)error;
{
  errno = 0;
  struct passwd *thePasswd = getpwnam(username);
  if (thePasswd) return [self initWithPasswd:thePasswd];

  if (error) {
    *error = errno ? [NSError currentPOSIXError] : nil;
  }
  return nil;
}


+ (User *)loginUserWithError:(NSError **)error;
{
  errno = 0;
  char const *loginName = getlogin();
  if (loginName) return [[self alloc] initWithUsername:loginName
                                                 error:error];

  if (error) {
    *error = errno ? [NSError currentPOSIXError] : nil;
  }
  return nil;
}


- (NSString *)name;
{
  return [NSString stringWithCString:passwd.pw_name
                            encoding:NSUTF8StringEncoding];
}


- (Group *)primaryGroupWithError:(NSError **)error;
{
  return [[Group alloc] initWithGID:passwd.pw_gid error:error];
}


+ (User *)realUserWithError:(NSError **)error;
{
  return [[self alloc] initWithUID:getuid() error:error];
}


- (NSString *)shell;
{
  return [NSString stringWithCString:passwd.pw_shell
                            encoding:NSUTF8StringEncoding];
}


- (uid_t)UID;
{
  return passwd.pw_uid;
}


- (char const *)userDir;
{
  return passwd.pw_dir;
}


- (char const *)username;
{
  return passwd.pw_name;
}


- (char const *)userShell;
{
  return passwd.pw_shell;
}


@end
