#import "AppInsights.h"

#if MSAI_FEATURE_METRICS

#import "MSAITelemetryContext.h"

@class MSAIContext;
@class MSAIAppClient;
@class MSAIChannel;
@class MSAITelemetryData;

extern NSString *const kMSAIApplicationWasLaunched;

@interface MSAIMetricsManager () {
}

+ (void)configureWithContext:(MSAIContext *)context appClient:(MSAIAppClient *)appClient;

+ (void)setDisableMetricsManager:(BOOL)disable;

+ (void)startManager;

///-----------------------------------------------------------------------------
/// @name Send data to channel
///-----------------------------------------------------------------------------

/**
 * Sends message to the channel.
 *
 * @param telemetry    telemetry object
 */
+ (void)trackDataItem:(MSAITelemetryData *)dataItem;

@end

#endif
