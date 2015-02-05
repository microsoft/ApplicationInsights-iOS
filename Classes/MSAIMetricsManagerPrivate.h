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
/// @name Forward data to channel
///-----------------------------------------------------------------------------

/**
 * Forwards the tracked data to the channel in order to send it.
 *
 * @param telemetry the data which should be sent to the server
 */
+ (void)trackDataItem:(MSAITelemetryData *)dataItem;

///-----------------------------------------------------------------------------
/// @name Helper
///-----------------------------------------------------------------------------

/**
 *  Returns if manager is enabled and configured.
 *
 *  @return YES if manager enabled and configured
 */
+ (BOOL)isMangerAvailable;

@end

#endif
