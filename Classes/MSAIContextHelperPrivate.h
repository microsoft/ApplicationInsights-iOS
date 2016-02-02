#import <Foundation/Foundation.h>
#import "MSAIContextHelper.h"

@class MSAISession;
@class MSAIUser;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const MSAISessionStartedNotification;
FOUNDATION_EXPORT NSString *const MSAISessionEndedNotification;
FOUNDATION_EXPORT NSString *const kMSAISessionInfo;

FOUNDATION_EXPORT NSString *const MSAIUserChangedNotification;
FOUNDATION_EXPORT NSString *const kMSAIUserInfo;

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

///-----------------------------------------------------------------------------
/// @name Manual User ID Management
///-----------------------------------------------------------------------------

/**
 *  Use this method to configure the current user's context.
 *
 *  @param userConfigurationBlock This block gets the current user as an input.
 *  Within the block you can update the user object's values to up-to-date.
 */
- (void)setUserWithConfigurationBlock:(void (^)(MSAIUser *user))userConfigurationBlock;

/**
 *  Set a new user. This method automatically adds this user to the automatic store with the current time as a timestamp.
 *
 *  @param user The string that represents the current user
 */
- (void)setCurrentUser:(nonnull MSAIUser *)user;

/**
 *  Method that return a persited user or nil if not available.
 *
 *  @return The persitet user instance
 */
- (MSAIUser *)loadUser;

/**
 *  Method that stores a user to NSUserDefaults.
 *
 *  @param user the user that should be stored
 */
- (void)saveUser:(MSAIUser *)user;

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
 *  @param userInfo A dictionary containing the new current user ID as kMSAIUserInfo.
 */
- (void)sendUserChangedNotificationWithUserInfo:(NSDictionary *)userInfo;

/**
 *  Send a notificaion when a new session has started.
 *
 *  @param userInfo A dictionary containing the new MSAISession object as kMSAISessionInfo.
 */
- (void)sendSessionStartedNotificationWithUserInfo:(NSDictionary *)userInfo;

/**
 *  Send a notification when a session has ended.
 */
- (void)sendSessionEndedNotification;

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
