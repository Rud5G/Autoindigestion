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
+ (User *)effectiveUserWithError:(NSError **)error;


- (NSNumber *)ID;


// Initialize a newly allocated user with a user ID.
// Returns nil if an error occurs looking up user information or the user
// does not exist.
//
// error
//   If not nil, points to an error object on return when an error occurred,
//   or points to nil on return when the user does not exist.
- (id)initWithID:(NSNumber *)ID
           error:(NSError **)error;


// Initialize a newly allocated user with a username.
// Returns nil if an error occurs looking up user information or the user
// does not exist.
//
// error
//   If not nil, points to an error object on return when an error occurred,
//   or points to nil on return when the user does not exist.
- (id)initWithName:(NSString *)name
             error:(NSError **)error;


- (id)initWithPasswd:(struct passwd *)thePasswd;


// Initialize a newly allocated user with a user ID.
// Returns nil if an error occurs looking up user information or the user
// does not exist.
//
// error
//   If not nil, points to an error object on return when an error occurred,
//   or points to nil on return when the user does not exist.
- (id)initWithUID:(uid_t)UID
            error:(NSError **)error;


// Initialize a newly allocated user with a username.
// Returns nil if an error occurs looking up user information or the user
// does not exist.
//
// error
//   If not nil, points to an error object on return when an error occurred,
//   or points to nil on return when the user does not exist.
- (id)initWithUsername:(char const *)username
                 error:(NSError **)error;


// Get the login user for the current process.
// Returns nil if an error occurs looking up user information or the login
// user cannot be found.
//
// error
//   If not nil, points to an error object on return when an error occurred,
//   or points to nil on return when the login user cannot be found.
+ (User *)loginUserWithError:(NSError **)error;


- (NSString *)name;


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
+ (User *)realUserWithError:(NSError **)error;


- (NSString *)shell;


- (uid_t)UID;


- (char const *)userDir;


- (char const *)username;


- (char const *)userShell;


@end
