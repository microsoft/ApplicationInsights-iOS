#import "AppInsights.h"

#if MSAI_FEATURE_METRICS

@class MSAITelemetryData;

extern NSString *const kMSAIApplicationWasLaunched;

@interface MSAIMetricsManager ()

/**
 *  This method should be called after the manager has been configured in order to create and send data.
 */
+ (void)startManager;

///-----------------------------------------------------------------------------
/// @name Forward data to channel
///-----------------------------------------------------------------------------

/**
 * Converts the tracked to an envelope object and forwards it to the channel.
 *
 * @param telemetry the data which should be forwareded by the channel
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
