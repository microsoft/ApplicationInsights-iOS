#import "AppInsights.h"

#if MSAI_FEATURE_METRICS

#import "MSAITelemetryContext.h"

@class MSAIContext;
@class MSAIAppClient;
@class MSAIChannel;
@class MSAITelemetryData;

extern NSString *const kMSAIApplicationWasLaunched;

@interface MSAIMetricsManager ()

///-----------------------------------------------------------------------------
/// @name Getters
///-----------------------------------------------------------------------------

/**
*  Creates the context which is part of the payload based on the app context.
*
*  @return a context which is used by the channel for creating the payload
*/
+ (MSAITelemetryContext *)telemetryContext;

/**
 *  Returns the channel.
 *
 *  @return the channel, which is used by the manager for sending out data
 */
+ (MSAIChannel *)channel;

/**
 *  Returns the context the manager has been configured with.
 *
 *  @return the context, which is used by the manager
 */
+ (MSAIContext *)context;

///-----------------------------------------------------------------------------
/// @name Forward data to channel
///-----------------------------------------------------------------------------

/**
 * Forwards the tracked data to the channel in order to send it.
 *
 * @param telemetry the data which should be sent to the server
 */
+ (void)trackDataItem:(MSAITelemetryData *)dataItem;

@end

#endif
