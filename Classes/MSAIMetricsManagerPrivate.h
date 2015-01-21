#import "AppInsights.h"

#if MSAI_FEATURE_METRICS

#import "MSAITelemetryContext.h"

@class MSAIContext;
@class MSAIAppClient;
@class MSAIChannel;
@class MSAITelemetryData;

@interface MSAIMetricsManager () {
}

- (instancetype)initWithAppContext:(MSAIContext *)appContext appClient:(MSAIAppClient *)appClient;

/**
 *  must be set
 */
@property (nonatomic, strong) MSAIAppClient *appClient;

/**
 *  used by MSAIMetricsManager if disable status is changed
 */
@property (nonatomic, getter = isMetricsManagerDisabled) BOOL disableMetricsManager;

- (MSAITelemetryContext *)telemetryContext;

///-----------------------------------------------------------------------------
/// @name Send data to channel
///-----------------------------------------------------------------------------

/**
 *  Telemetry channel for enqueueing metric data
 */
@property (nonatomic, strong, readonly) MSAIChannel *telemetryChannel;

/**
 * Sends message to the channel.
 *
 * @param telemetry    telemetry object
 */
- (void)trackDataItem:(MSAITelemetryData *)dataItem;

@end

#endif
