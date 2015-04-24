#import <Foundation/Foundation.h>
#import "MSAISessionHelper.h"
#import "MSAISession.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSAISessionHelper()

FOUNDATION_EXPORT NSString *const MSAISessionStartedNotification;
FOUNDATION_EXPORT NSString *const MSAISessionEndedNotification;
FOUNDATION_EXPORT NSString *const kMSAISessionInfoSession;

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
+ (MSAISession *)startNewSession;

/**
 *  Start a new session if the method is called more than 20 seconds after app went to background for the last time.
 */
+ (MSAISession *)startNewSessionIfNeeded;


/**
 *  Start a new session.
 */
- (MSAISession *)startNewSession;

/**
 *  Start a new session if the method is called more than 20 seconds after app went to background for the last time.
 */
- (MSAISession *)startNewSessionIfNeeded;


///-----------------------------------------------------------------------------
/// @name Adding a session
///-----------------------------------------------------------------------------

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
 *  @param date the creation date of a crash report
 *
 *  @return the sessionId of the session, in which the crash occured
 */
+ (MSAISession *)sessionForDate:(NSDate *)date;

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
+ (void)removeSession:(MSAISession *)session;

/**
 *  Keep the most recent sessionId, but remove all other entries from the plist.
 *  This should only be called after you made sure you won't need any other session IDs anymore.
 */
+ (void)cleanUpSessions;

/**
 *  Removes the entry for a given sessionId.
 *
 *  @param sessionId the sessionId of the plist entry, which should be removed
 */
- (void)removeSession:(MSAISession *)session;

/**
 *  Keep the most recent sessionId, but all other entries from the plist
 */
- (void)cleanUpSessions;

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
 *  Registers MSAISessionHelper for several notifications, which influence the session state.
 */
- (void)registerObservers;

/**
 *  Unegisters MSAISessionHelper for several notifications, which influence the session state.
 */
- (void)unregisterObservers;

@end
NS_ASSUME_NONNULL_END
