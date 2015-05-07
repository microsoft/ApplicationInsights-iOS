#import <Foundation/Foundation.h>
#import "MSAIContextHelper.h"
#import "MSAISession.h"
#import "MSAIUser.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const MSAISessionStartedNotification;
FOUNDATION_EXPORT NSString *const MSAISessionEndedNotification;
FOUNDATION_EXPORT NSString *const kMSAISessionInfoSession;

FOUNDATION_EXPORT NSString *const MSAIUserIdChangedNotification;
FOUNDATION_EXPORT NSString *const kMSAIUserInfoUserId;

FOUNDATION_EXPORT NSString *const kMSAIApplicationWasLaunched;

@interface MSAIContextHelper ()

///-----------------------------------------------------------------------------
/// @name Shared Instance
///-----------------------------------------------------------------------------

/**
 *  A serial queue which makes makes insert/remove operations thread safe.
 */
@property (nonatomic, strong) dispatch_queue_t operationsQueue;

/**
 *  A Dictionary which holds content of property list in memory.
 */
@property (nonatomic, strong) NSMutableDictionary *metaData;

/**
 *  This flag determines if the helper automatically renews sessions.
 */
@property BOOL autoSessionManagementDisabled;

/**
 *  Returns the shared instance.
 *
 *  @return the shared instance
 */
+ (instancetype)sharedInstance;


///-----------------------------------------------------------------------------
/// @name User Creation
///-----------------------------------------------------------------------------

/**
 *  Creates a new user
 *
 *  @return A new user object with a random user ID
 *  @see newUserWithId:
 */
- (MSAIUser *)newUser;

/**
 *  Creates a new user with a given user ID
 *
 *  @param userId A string which will be used as the user object's user ID
 *
 *  @return A new user object with the given ID
 *  @see newUser
 */
- (MSAIUser *)newUserWithId:(NSString *)userId;


///-----------------------------------------------------------------------------
/// @name Manual User ID Management
///-----------------------------------------------------------------------------

/**
 *  Set a new user ID. This method automatically adds this ID to the automatic store with the current time as a timestamp.
 *
 *  @param userId The string that represents the current user's ID
 */
- (void)setCurrentUserId:(NSString *)userId;

/**
 *  Add a MSAIUser object to the automatic meta data store.
 *
 *  @param user Any MSAIUser object which should be stored for later reference.
 *  @param date The time and date when the user object started to be the current user.
 */
- (void)addUser:(MSAIUser *)user forDate:(NSDate *)date;

/**
 *  Retrieve the latest user object for a given date.
 *
 *  @param date The date for which the user should be retrieved.
 *
 *  @return The most current user for the given date parameter.
 */
- (MSAIUser *)userForDate:(NSDate *)date;

/**
 *  Remove a specific user ID from the persistent storage.
 *
 *  @param userId The user ID to be removed.
 *
 *  @return Returns YES if the ID was found and successfully removed.
 */
- (BOOL)removeUserId:(NSString *)userId;


///-----------------------------------------------------------------------------
/// @name Creating A New Session
///-----------------------------------------------------------------------------

/**
 *  Creates a new user
 *
 *  @return A new session object with a random session ID
 *  @see newSessionWithId:
 */
- (MSAISession *)newSession;

/**
 *  Creates a new session with a given session ID
 *
 *  @param sessionId A string which will be used as the user object's session ID
 *
 *  @return A new session object with the given ID
 *  @see newSession
 */
- (MSAISession *)newSessionWithId:(NSString *)sessionId;


///-----------------------------------------------------------------------------
/// @name Automatic Session Management
///-----------------------------------------------------------------------------

/**
 *  Registers MSAIContextHelper for several notifications, which influence the session state.
 */
- (void)registerObservers;

/**
 *  Unegisters MSAIContextHelper for several notifications, which influence the session state.
 */
- (void)unregisterObservers;

/**
 *  This is called whenever the app enters the background and saves the current time to NSUserDefaults.
 */
- (void)updateDidEnterBackgroundTime;

/**
 *  Start a new session if the method is called more than 20 seconds after app went to background for the last time.
 */
- (void)startNewSessionIfNeeded;


///-----------------------------------------------------------------------------
/// @name Manual Session Management
///-----------------------------------------------------------------------------

- (void)renewSessionWithId:(NSString *)sessionId;

/**
 *  Adds a new sessionId (value) for a given timestamp (key) to the session plist.
 *
 *  @param sessionId the sessionId (value)
 *  @param timestamp the timestamp, which represents the creation of the session
 */
- (void)addSession:(MSAISession *)session withDate:(NSDate *)date;

/**
 *  Returns the best effort based on a given timestamp.
 *
 *
 *  @param date the creation date of a crash report
 *
 *  @return the sessionId of the session, in which the crash occured
 */
- (MSAISession *)sessionForDate:(NSDate *)date;

/**
 *  Removes the entry for a given sessionId.
 *
 *  @param sessionId The session ID of the plist entry which should be removed
 *
 *  @return Returns YES if the ID was found and successfully removed.
 */
- (BOOL)removeSession:(MSAISession *)session;


///-----------------------------------------------------------------------------
/// @name Session Lifecycle
///-----------------------------------------------------------------------------

/**
 *  Start a new session with a random session ID.
 */
- (void)startNewSession;

/**
 *  End the current session. Currently only triggers the sending of the MSAISessionEndedNotification.
 */
- (void)endSession;


///-----------------------------------------------------------------------------
/// @name Sending Notifications
///-----------------------------------------------------------------------------

/**
 *  Send a notification when the current user has changed.
 *
 *  @param userInfo A dictionary containing the new current user ID as kMSAIUserInfoUserId.
 */
- (void)sendUserIdChangedNotificationWithUserInfo:(NSDictionary *)userInfo;

/**
 *  Send a notificaion when a new session has started.
 *
 *  @param userInfo A dictionary containing the new MSAISession object as kMSAISessionInfoSession.
 */
- (void)sendSessionStartedNotificationWithUserInfo:(NSDictionary *)userInfo;

/**
 *  Send a notification when a session has ended.
 */
- (void)sendSessionEndedNotification;


///-----------------------------------------------------------------------------
/// @name Clean Up
///-----------------------------------------------------------------------------

/**
 *  Remove everything except the most recent entries of each meta data type from the persistent store.
 */
- (void)cleanUpMetaData;


///-----------------------------------------------------------------------------
/// @name Helper
///-----------------------------------------------------------------------------

/**
 *  Turn a NSDate object into a unix time timestamp
 *
 * @param date any NSDate object
 *
 * @returns a string containing the date as a Unix timestamp
 */
- (NSString *)unixTimestampFromDate:(NSDate *)date;

@end
NS_ASSUME_NONNULL_END
