#import <pwd.h>
#import "User.h"

#import "Group.h"
#import "NSError+Autoindigestion.h"


static void freePasswdMemory(struct passwd *passwd);


@implementation User


@synthesize passwd;


- (void)dealloc;
{
  freePasswdMemory(&passwd);
}


- (NSString *)description;
{
  return passwd.pw_name ? [self name] : @"(NULL)";
}


- (NSString *)directory;
{
  if (passwd.pw_dir) {
    return [NSString stringWithCString:passwd.pw_dir
                              encoding:NSUTF8StringEncoding];
  } else {
    return nil;
  }
}


+ (User *)effectiveUserWithError:(NSError **)error;
{
  return [[self alloc] initWithUID:geteuid() error:error];
}


- (NSString *)fullName;
{
  if (passwd.pw_gecos) {
    return [NSString stringWithCString:passwd.pw_gecos
                              encoding:NSUTF8StringEncoding];
  } else {
    return nil;
  }
}


- (gid_t)GID;
{
  return passwd.pw_gid;
}


- (NSNumber *)ID;
{
  return [NSNumber numberWithUnsignedLong:passwd.pw_uid];
}


- (id)init;
{
  [NSException raise:@"Not Implemented" format:@"%s", __FUNCTION__];
  return nil;
}


- (id)initWithID:(NSNumber *)ID
           error:(NSError **)error;
{
  uid_t UID = [ID unsignedIntValue];
  return [self initWithUID:UID error:error];
}


- (id)initWithName:(NSString *)name
             error:(NSError **)error;
{
  char const *username = [name UTF8String];
  return [self initWithUsername:username error:error];
}


- (id)initWithPasswd:(struct passwd *)thePasswd;
{
  self = [super init];
  if ( ! self) return nil;
  
  if (thePasswd->pw_name) {
    passwd.pw_name = strdup(thePasswd->pw_name);
    if ( ! passwd.pw_name) return nil;
  }
  
  if (thePasswd->pw_passwd) {
    passwd.pw_passwd = strdup(thePasswd->pw_passwd);
    if ( ! passwd.pw_passwd) {
      freePasswdMemory(&passwd);
      return nil;
    }
  }
  
  passwd.pw_uid = thePasswd->pw_uid;
  passwd.pw_gid = thePasswd->pw_gid;
  passwd.pw_change = thePasswd->pw_change;
  
  if (thePasswd->pw_class) {    
    passwd.pw_class = strdup(thePasswd->pw_class);
    if ( ! passwd.pw_class) {
      freePasswdMemory(&passwd);
      return nil;
      
    }
  }
  
  if (thePasswd->pw_gecos) {
    passwd.pw_gecos = strdup(thePasswd->pw_gecos);
    if ( ! passwd.pw_gecos) {
      freePasswdMemory(&passwd);
      return nil;
    }
  }
  
  if (thePasswd->pw_dir) {
    passwd.pw_dir = strdup(thePasswd->pw_dir);
    if ( ! passwd.pw_dir) {
      freePasswdMemory(&passwd);
      return nil;
    }
  }
  
  if (thePasswd->pw_shell) {
    passwd.pw_shell = strdup(thePasswd->pw_shell);
    if ( ! passwd.pw_shell) {
      freePasswdMemory(&passwd);
      return nil;
    }
  }
  
  passwd.pw_expire = thePasswd->pw_expire;
  
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
  if (passwd.pw_name) {
    return [NSString stringWithCString:passwd.pw_name
                              encoding:NSUTF8StringEncoding];
  } else {
    return nil;
  }
}


- (NSString *)password;
{
  if (passwd.pw_passwd) {
    return [NSString stringWithCString:passwd.pw_passwd
                              encoding:NSUTF8StringEncoding];
  } else {
    return nil;
  }
}


- (NSNumber *)primaryGroupID;
{
  return [NSNumber numberWithUnsignedLong:passwd.pw_gid];
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
  if (passwd.pw_shell) {
    return [NSString stringWithCString:passwd.pw_shell
                              encoding:NSUTF8StringEncoding];
  } else {
    return nil;
  }
}


- (uid_t)UID;
{
  return passwd.pw_uid;
}


@end


static void freePasswdMemory(struct passwd *passwd)
{
  free(passwd->pw_shell);
  free(passwd->pw_dir);
  free(passwd->pw_gecos);
  free(passwd->pw_class);
  free(passwd->pw_passwd);
  free(passwd->pw_name);
}
