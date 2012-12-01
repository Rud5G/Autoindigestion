#import <pwd.h>
#import "User.h"

#import "Group.h"
#import "NSError+Autoindigestion.h"


static void freePasswdMemory(struct passwd *passwd);


@implementation User


- (void)dealloc;
{
  freePasswdMemory(&_passwd);
}


- (NSString *)description;
{
  return _passwd.pw_name ? [self name] : @"(NULL)";
}


- (NSString *)directory;
{
  if (_passwd.pw_dir) {
    return [NSString stringWithCString:_passwd.pw_dir
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
  if (_passwd.pw_gecos) {
    return [NSString stringWithCString:_passwd.pw_gecos
                              encoding:NSUTF8StringEncoding];
  } else {
    return nil;
  }
}


- (gid_t)GID;
{
  return _passwd.pw_gid;
}


- (NSNumber *)ID;
{
  return [NSNumber numberWithUnsignedLong:_passwd.pw_uid];
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
    _passwd.pw_name = strdup(thePasswd->pw_name);
    if ( ! _passwd.pw_name) return nil;
  }
  
  if (thePasswd->pw_passwd) {
    _passwd.pw_passwd = strdup(thePasswd->pw_passwd);
    if ( ! _passwd.pw_passwd) {
      freePasswdMemory(&_passwd);
      return nil;
    }
  }

  _passwd.pw_uid = thePasswd->pw_uid;
  _passwd.pw_gid = thePasswd->pw_gid;
  _passwd.pw_change = thePasswd->pw_change;
  
  if (thePasswd->pw_class) {
    _passwd.pw_class = strdup(thePasswd->pw_class);
    if ( ! _passwd.pw_class) {
      freePasswdMemory(&_passwd);
      return nil;
      
    }
  }
  
  if (thePasswd->pw_gecos) {
    _passwd.pw_gecos = strdup(thePasswd->pw_gecos);
    if ( ! _passwd.pw_gecos) {
      freePasswdMemory(&_passwd);
      return nil;
    }
  }
  
  if (thePasswd->pw_dir) {
    _passwd.pw_dir = strdup(thePasswd->pw_dir);
    if ( ! _passwd.pw_dir) {
      freePasswdMemory(&_passwd);
      return nil;
    }
  }
  
  if (thePasswd->pw_shell) {
    _passwd.pw_shell = strdup(thePasswd->pw_shell);
    if ( ! _passwd.pw_shell) {
      freePasswdMemory(&_passwd);
      return nil;
    }
  }

  _passwd.pw_expire = thePasswd->pw_expire;
  
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
  if (_passwd.pw_name) {
    return [NSString stringWithCString:_passwd.pw_name
                              encoding:NSUTF8StringEncoding];
  } else {
    return nil;
  }
}


- (NSString *)password;
{
  if (_passwd.pw_passwd) {
    return [NSString stringWithCString:_passwd.pw_passwd
                              encoding:NSUTF8StringEncoding];
  } else {
    return nil;
  }
}


- (NSNumber *)primaryGroupID;
{
  return [NSNumber numberWithUnsignedLong:_passwd.pw_gid];
}


- (Group *)primaryGroupWithError:(NSError **)error;
{
  return [[Group alloc] initWithGID:_passwd.pw_gid error:error];
}


+ (User *)realUserWithError:(NSError **)error;
{
  return [[self alloc] initWithUID:getuid() error:error];
}


- (NSString *)shell;
{
  if (_passwd.pw_shell) {
    return [NSString stringWithCString:_passwd.pw_shell
                              encoding:NSUTF8StringEncoding];
  } else {
    return nil;
  }
}


- (uid_t)UID;
{
  return _passwd.pw_uid;
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
