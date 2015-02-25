#import "AppInsights.h"

#if MSAI_FEATURE_METRICS

@class MSAITelemetryData;

extern NSString *const kMSAIApplicationWasLaunched;

@interface MSAIMetricsManager ()

///-----------------------------------------------------------------------------
/// @name Start the manager
///-----------------------------------------------------------------------------

/**
 *  A flag which determines whether the manager has been enabled and started, yet.
 */
@property BOOL managerInitialised;

/**
 *  Flag which determines whether the manager is enabled or not. This can only be set before the
 *  manager has been started.
 */
@property BOOL metricsManagerDisabled;

/**
 *  This method should be called after the manager has been configured in order to create and send data.
 */
- (void)startManager;

///-----------------------------------------------------------------------------
/// @name Forward data to channel
///-----------------------------------------------------------------------------

/**
 *  A concurrent queue which creates telemetry objects and forwards them to the channel.
 */
@property (nonatomic, strong)dispatch_queue_t metricEventQueue;

/**
 * Converts the tracked to an envelope object and forwards it to the channel.
 *
 * @param telemetry the data which should be forwareded by the channel
 */
- (void)trackDataItem:(MSAITelemetryData *)dataItem;

/**
 * Registers the manager for all notifications that are necessary for automatic session tracking
 */
- (void)registerObservers;

@end

#endif
