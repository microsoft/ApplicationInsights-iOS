#import "AppInsights.h"

#if MSAI_FEATURE_METRICS

@class MSAIAppClient;

@interface MSAIMetricsManager () {
}

/**
 * must be set
 */
@property (nonatomic, strong) MSAIAppClient *appClient;

// used by MSAIMetricsManager if disable status is changed
@property (nonatomic, getter = isMetricsManagerDisabled) BOOL disableMetricsManager;

/**
 To send data in background
 */
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;


/**
 * Removes the stored first_time setup, so the next session will be reported as first_session again
 *
 * Call this before invoking `startManager`!
 */
- (void) cleanupInternalStorage;


@end

#endif
