#import <Foundation/Foundation.h>
#import <pwd.h>


@class Group;


@interface User : NSObject

@property (readonly) struct passwd passwd;

- (NSString *)directory;

// Get the effective user for the current process.
// Returns nil if an error occurs looking up user information.
//
// error
//   If not nil, points to an error object on return when an error occurred.
+ (instancetype)effectiveUserWithError:(NSError **)error;

- (NSString *)fullName;

- (gid_t)GID;

- (NSNumber *)ID;

// Initialize a newly allocated user with a user ID.
// Returns nil if an error occurs looking up user information or the user
// does not exist.
//
// error
//   If not nil, points to an error object on return when an error occurred,
//   or points to nil on return when the user does not exist.
- (instancetype)initWithID:(NSNumber *)ID
                     error:(NSError **)error;

// Initialize a newly allocated user with a username.
// Returns nil if an error occurs looking up user information or the user
// does not exist.
//
// error
//   If not nil, points to an error object on return when an error occurred,
//   or points to nil on return when the user does not exist.
- (instancetype)initWithName:(NSString *)name
                       error:(NSError **)error;

- (instancetype)initWithPasswd:(struct passwd *)thePasswd;

// Initialize a newly allocated user with a user ID.
// Returns nil if an error occurs looking up user information or the user
// does not exist.
//
// error
//   If not nil, points to an error object on return when an error occurred,
//   or points to nil on return when the user does not exist.
- (instancetype)initWithUID:(uid_t)UID
                      error:(NSError **)error;

// Initialize a newly allocated user with a username.
// Returns nil if an error occurs looking up user information or the user
// does not exist.
//
// error
//   If not nil, points to an error object on return when an error occurred,
//   or points to nil on return when the user does not exist.
- (instancetype)initWithUsername:(char const *)username
                           error:(NSError **)error;

// Get the login user for the current process.
// Returns nil if an error occurs looking up user information or the login
// user cannot be found.
//
// error
//   If not nil, points to an error object on return when an error occurred,
//   or points to nil on return when the login user cannot be found.
+ (instancetype)loginUserWithError:(NSError **)error;

- (NSString *)name;

- (NSString *)password;

- (NSNumber *)primaryGroupID;

// Get the primary group for the user.
// Returns nil if an error occurs looking up group information or the group
// does not exist.
//
// error
//   If not nil, points to an error object on return when an error occurred,
//   or points to nil on return when the group does not exist.
- (Group *)primaryGroupWithError:(NSError **)error;

// Get the real user for the current process.
// Returns nil if an error occurs looking up user information.
//
// error
//   If not nil, points to an error object on return when an error occurred.
+ (instancetype)realUserWithError:(NSError **)error;

- (NSString *)shell;

- (uid_t)UID;

@end
