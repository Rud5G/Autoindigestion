#import <Foundation/Foundation.h>
#import <grp.h>


@interface Group : NSObject

@property (readonly) struct group group;

// Get the effective group for the current process.
// Returns nil if an error occurs looking up group information.
//
// error
//   If not nil, points to an error object on return when an error occurred.
+ (instancetype)effectiveGroupWithError:(NSError **)error;

- (gid_t)GID;

- (NSNumber *)ID;

// Initialize a newly allocated group with a group ID.
// Returns nil if an error occurs looking up group information or the group
// does not exist.
//
// error
//   If not nil, points to an error object on return when an error occurred,
//   or points to nil on return when the group does not exist.
- (instancetype)initWithGID:(gid_t)GID
                      error:(NSError **)error;

- (instancetype)initWithGroup:(struct group *)theGroup;

// Initialize a newly allocated group with a group name.
// Returns nil if an error occurs looking up group information or the group
// does not exist.
//
// error
//   If not nil, points to an error object on return when an error occurred,
//   or points to nil on return when the group does not exist.
- (instancetype)initWithGroupName:(char const *)groupName
                            error:(NSError **)error;

// Initialize a newly allocated group with a group ID.
// Returns nil if an error occurs looking up group information or the group
// does not exist.
//
// error
//   If not nil, points to an error object on return when an error occurred,
//   or points to nil on return when the group does not exist.
- (instancetype)initWithID:(NSNumber *)ID
                     error:(NSError **)error;

// Initialize a newly allocated group with a group name.
// Returns nil if an error occurs looking up group information or the group
// does not exist.
//
// error
//   If not nil, points to an error object on return when an error occurred,
//   or points to nil on return when the group does not exist.
- (instancetype)initWithName:(NSString *)name
                       error:(NSError **)error;

// Return an array of user names that belong to this group.
- (NSArray *)memberNames;

// Return an array of User objects for users that belong to this group.
// Returns nil if an error occurs looking up user information or if the group
// contains a user that does not exist.
//
// error
//   If not nil, points to an error object on return when an error occurred,
//   or points to nil on return when the group contains a user that does not
//   exist.
- (NSArray *)membersWithError:(NSError **)error;

- (NSString *)name;

// Get the real group for the current process.
// Returns nil if an error occurs looking up group information.
//
// error
//   If not nil, points to an error object on return when an error occurred.
+ (instancetype)realGroupWithError:(NSError **)error;

@end
