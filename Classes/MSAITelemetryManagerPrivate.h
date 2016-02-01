#import "ApplicationInsights.h"

#if MSAI_FEATURE_TELEMETRY

#import "MSAITelemetryManager.h"

@class MSAITelemetryData;

NS_ASSUME_NONNULL_BEGIN
@interface MSAITelemetryManager ()

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
@property BOOL telemetryManagerDisabled;

/**
 *  This method should be called after the manager has been configured in order to create and send data.
 */
- (void)startManager;

///-----------------------------------------------------------------------------
/// @name Forward data to channel
///-----------------------------------------------------------------------------

/**
 *  A flag which determines rather collecting page views automatically is enabled or not.
 *  NO by default.
 */
@property BOOL autoPageViewTrackingDisabled;

/**
 *  A concurrent queue which creates telemetry objects and forwards them to the channel.
 */
@property (nonatomic, strong)dispatch_queue_t telemetryEventQueue;

/**
 *  A concurrent queue which makes writing and accessing the commonProperties thread-safe.
 */
@property (nonatomic, strong) dispatch_queue_t commonPropertiesQueue;

/**
 *  Helper method that converts am NSTimeInterval value to a string of the format "d:hh:mm:ss.fffffff"
 */
- (NSString *)durationStringFromDuration:(NSTimeInterval)duration;

/**
 * Converts the tracked to an envelope object and forwards it to the channel.
 *
 * @param telemetry the data which should be forwarded by the channel
 */
- (void)trackDataItem:(MSAITelemetryData *)dataItem;

/**
 * Registers the manager for all notifications that are necessary for automatic session tracking
 */
- (void)registerObservers;

/**
 * Disable notifications for automatic session tracking.
 */
- (void)unregisterObservers;

@end
NS_ASSUME_NONNULL_END

#endif /* MSAI_FEATURE_METRICS */
