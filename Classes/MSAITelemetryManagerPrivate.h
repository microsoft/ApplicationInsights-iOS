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
 * Flag that determines whether the Telemetry Manager should be disabled.
 * If this flag is enabled, then telemetry collection is disabled and telemetry data will
 * not be collected and send.
 *
 * @return YES, if manager is disabled
 *
 * @default NO
 * @see MSAITelemetryManager
 * @warning This property needs to be set before calling `start`
 */
@property (nonatomic, getter = isTelemetryManagerDisabled) BOOL telemetryManagerDisabled;

/**
 *  Enable (NO) or disable (YES) the telemetry manager. This should be called before `start`.
 *
 *  @param telemetryManagerDisabled Flag which determines whether the Telemetry Manager should be disabled
 */
+ (void)setTelemetryManagerDisabled:(BOOL)telemetryManagerDisabled;

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
@property (nonatomic, strong)dispatch_queue_t telemetryEventQueue;

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
