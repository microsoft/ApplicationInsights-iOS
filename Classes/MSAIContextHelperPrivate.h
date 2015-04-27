#import <Foundation/Foundation.h>
#import "MSAIContextHelper.h"
#import "MSAISession.h"
#import "MSAIUser.h"

FOUNDATION_EXPORT NSString *const MSAISessionStartedNotification;
FOUNDATION_EXPORT NSString *const MSAISessionEndedNotification;
FOUNDATION_EXPORT NSString *const kMSAISessionInfoSession;

FOUNDATION_EXPORT NSString *const MSAIUserIdChangedNotification;
FOUNDATION_EXPORT NSString *const kMSAIUserInfoUserId;

FOUNDATION_EXPORT NSString *const kMSAIApplicationWasLaunched;

@interface MSAIContextHelper ()

///-----------------------------------------------------------------------------
/// @name Getting shared instance
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

- (MSAIUser *)newUser;
- (MSAIUser *)newUserWithId:(NSString *)userId;

///-----------------------------------------------------------------------------
/// @name Starting a session
///-----------------------------------------------------------------------------

/**
 *  Start a new session.
 */
- (void)startNewSession;

/**
 *  Start a new session if the method is called more than 20 seconds after app went to background for the last time.
 */
- (void)startNewSessionIfNeeded;

- (MSAISession *)newSession;

- (MSAISession *)newSessionWithId:(NSString *)sessionId;

///-----------------------------------------------------------------------------
/// @name Adding a session
///-----------------------------------------------------------------------------

- (void)renewSessionWithId:(NSString *)sessionId;

/**
 *  Adds a new sessionId (value) for a given timestamp (key) to the session plist.
 *
 *  @param sessionId the sessionId (value)
 *  @param timestamp the timestamp, which represents the creation of the session
 */
- (void)addSession:(MSAISession *)session withDate:(NSDate *)date;

///-----------------------------------------------------------------------------
/// @name Getting a session
///-----------------------------------------------------------------------------

/**
 *  Returns the best effort based on a given timestamp.
 *
 *
 *  @param date the creation date of a crash report
 *
 *  @return the sessionId of the session, in which the crash occured
 */
- (MSAISession *)sessionForDate:(NSDate *)date;

///-----------------------------------------------------------------------------
/// @name Removing sessions
///-----------------------------------------------------------------------------

/**
 *  Removes the entry for a given sessionId.
 *
 *  @param sessionId the sessionId of the plist entry, which should be removed
 */
- (void)removeSession:(MSAISession *)session;

///-----------------------------------------------------------------------------
/// @name Clean Up
///-----------------------------------------------------------------------------

/**
 *  Keep the most recent sessionId, but all other entries from the plist
 */
- (void)cleanUpMetaData;

///-----------------------------------------------------------------------------
/// @name User IDs
///-----------------------------------------------------------------------------

- (void)setCurrentUserId:(NSString *)userId;

/**
 *  <#Description#>
 *
 *  @param user <#user description#>
 */
- (void)addUser:(MSAIUser *)user forDate:(NSDate *)date;

/**
 *  <#Description#>
 *
 *  @param date <#date description#>
 *
 *  @return <#return value description#>
 */
- (MSAIUser *)userForDate:(NSDate *)date;


///-----------------------------------------------------------------------------
/// @name Helper
///-----------------------------------------------------------------------------

/**
 *  This is called whenever the app enters the background and saves the current time to NSUserDefaults.
 */
- (void)updateDidEnterBackgroundTime;

/**
 *  Turn a NSDate object into a unix time timestamp
 *
 * @param date any NSDate object
 *
 * @returns a string containing the date as a Unix timestamp
 */
- (NSString *)unixTimestampFromDate:(NSDate *)date;

/**
 *  Registers MSAIContextHelper for several notifications, which influence the session state.
 */
- (void)registerObservers;

/**
 *  Unegisters MSAIContextHelper for several notifications, which influence the session state.
 */
- (void)unregisterObservers;

@end
