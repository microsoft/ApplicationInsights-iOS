#import <Foundation/Foundation.h>

@interface MSAISessionHelper : NSObject

///-----------------------------------------------------------------------------
/// @name Adding a session
///-----------------------------------------------------------------------------

/**
 *  Adds a new sessionId (value) for a given timestamp (key) to the session plist.
 *
 *  @param sessionId the sessionId (value)
 *  @param timestamp the timestamp, which represents the creation of the session
 */
+ (void)addSessionId:(NSString *)sessionId withTimestamp:(NSString *)timestamp;

///-----------------------------------------------------------------------------
/// @name Getting a session
///-----------------------------------------------------------------------------

/**
 *  Returns the best effort based on a given timestamp.
 *
 *
 *  @param timestamp the creation timestamp of a crash report
 *
 *  @return the sessionId of the session, in which the crash occured
 */
+ (NSString *)sessionIdForTimestamp:(NSString *)timestamp;

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
 *  Keep the most recent sessionId, but all other entries from the plist
 */
+ (void)cleanUpSessionIds;

@end
