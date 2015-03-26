#import <Foundation/Foundation.h>
#import "MSAISessionHelper.h"

@interface MSAISessionHelper()

FOUNDATION_EXPORT NSString *const MSAISessionStartedNotification;
FOUNDATION_EXPORT NSString *const MSAISessionEndedNotification;
FOUNDATION_EXPORT NSString *const kMSAISessionInfoSessionId;

FOUNDATION_EXPORT NSString *const kMSAIApplicationWasLaunched;

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
@property (nonatomic, strong) NSMutableDictionary *sessionEntries;

/**
 *  Returns the shared instance.
 *
 *  @return the shared instance
 */
+ (id)sharedInstance;

///-----------------------------------------------------------------------------
/// @name Starting a session
///-----------------------------------------------------------------------------

/**
 *  Start a new session.
 */
+ (void)startSession;

/**
 *  Start a new session.
 */
- (void)startSession;

///-----------------------------------------------------------------------------
/// @name Adding a session
///-----------------------------------------------------------------------------

/**
 *  Adds a new sessionId (value) for a given timestamp (key) to the session plist.
 *
 *  @param sessionId the sessionId (value)
 *  @param date the date, which represents the creation time of the session
 */
+ (void)addSessionId:(NSString *)sessionId withDate:(NSDate *)date;

/**
 *  Adds a new sessionId (value) for a given timestamp (key) to the session plist.
 *
 *  @param sessionId the sessionId (value)
 *  @param timestamp the timestamp, which represents the creation of the session
 */
- (void)addSessionId:(NSString *)sessionId withDate:(NSDate *)date;

///-----------------------------------------------------------------------------
/// @name Getting a session
///-----------------------------------------------------------------------------

/**
 *  Returns the best effort based on a given timestamp.
 *
 *  @param date the creation date of a crash report
 *
 *  @return the sessionId of the session, in which the crash occured
 */
+ (NSString *)sessionIdForDate:(NSDate *)date;

/**
 *  Returns the best effort based on a given timestamp.
 *
 *
 *  @param date the creation date of a crash report
 *
 *  @return the sessionId of the session, in which the crash occured
 */
- (NSString *)sessionIdForDate:(NSDate *)date;

///-----------------------------------------------------------------------------
/// @name Removing sessions
///-----------------------------------------------------------------------------

/**
 *  Removes the entry for a given sessionId.
 *
 *  @param sessionId the sessionId of the plist entry, which should be removed
 */
+ (void)removeSessionId:(NSString *)sessionId;

/**
 *  Keep the most recent sessionId, but remove all other entries from the plist.
 *  This should only be called after you made sure you won't need any other session IDs anymore.
 */
+ (void)cleanUpSessionIds;

/**
 *  Removes the entry for a given sessionId.
 *
 *  @param sessionId the sessionId of the plist entry, which should be removed
 */
- (void)removeSessionId:(NSString *)sessionId;

/**
 *  Keep the most recent sessionId, but all other entries from the plist
 */
- (void)cleanUpSessionIds;

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

/**
 *  Registers MSAISessionHelper for several notifications, which influence the session state.
 */
- (void)registerObservers;

/**
 *  Unegisters MSAISessionHelper for several notifications, which influence the session state.
 */
- (void)unregisterObservers;

@end
