#import <Foundation/Foundation.h>

/**
 *  A helper class that allows to persist and retrieve session IDs attached to different timestamps.
 */
@interface MSAISessionHelper : NSObject

FOUNDATION_EXPORT NSString *const MSAISessionStartedNotification;
FOUNDATION_EXPORT NSString *const MSAISessionEndedNotification;
FOUNDATION_EXPORT NSString *const kMSAISessionInfoSessionId;

FOUNDATION_EXPORT NSString *const kMSAIApplicationWasLaunched;
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

@end
