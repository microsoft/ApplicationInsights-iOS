#import "MSAIBaseManager.h"

@interface MSAIMetricsManager : MSAIBaseManager

///-----------------------------------------------------------------------------
/// @name Track data
///-----------------------------------------------------------------------------

/**
 *  Track the event by event name.
 *
 *  @param eventName the name of the event, which should be tracked.
 */
- (void)trackEventWithName:(NSString *)eventName;

/**
 *  Track the event by event name and customized properties.
 *
 *  @param eventName the name of the event, which should be tracked.
 *  @param properties key value pairs with additional info about the event.
 */
- (void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties;

/**
 *  Track the event by event name and customized properties and metrics.
 *
 *  @param eventName the name of the event, which should be tracked.
 *  @param properties key value pairs with additional info about the event.
 *  @param measurements key value pairs, which contain custom metrics.
 */
- (void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties mesurements:(NSDictionary *)measurements;

/**
 *  Track by message.
 *
 *  @param message a message, which should be tracked.
 */
- (void)trackTraceWithMessage:(NSString *)message;

/**
 *  Track with the message and custom properties.
 *
 *  @param message a message, which should be tracked.
 *  @param properties key value pairs with additional info about the trace.
 */
- (void)trackTraceWithMessage:(NSString *)message properties:(NSDictionary *)properties;

/**
 *  Track metric by name and value.
 *
 *  @param metricName the name of the metric.
 *  @param value a numeric value, which should be tracked.
 */
- (void)trackMetricWithName:(NSString *)metricName value:(double)value;

/**
 *  Track metric by name and value and custom properties.
 *
 *  @param metricName the name of the metric.
 *  @param value a numeric value, which should be tracked.
 *  @param properties key value pairs with additional info about the metric.
 */
- (void)trackMetricWithName:(NSString *)metricName value:(double)value properties:(NSDictionary *)properties;

/**
 * Sends information about a page view to Application Insights.
 *
 * @param pageName the name of the page
 */
- (void)trackPageView:(NSString *)pageName;

/**
 * Sends information about a page view to Application Insights.
 *
 * @param pageName the name of the page
 * @param pageLoadDurationMs the duration of the page load
 */
- (void)trackPageView:(NSString *)pageName duration:(long)pageLoadDurationMs;

/**
 * Sends information about a page view to Application Insights.
 *
 * @param pageName the name of the page
 * @param pageLoadDurationMs the duration of the page load
 * @param properties custom properties
 */
- (void)trackPageView:(NSString *)pageName  duration:(long)pageLoadDurationMs properties:(NSDictionary *)properties;

/**
 * Sends information about a page view to Application Insights.
 *
 * @param pageName the name of the page
 * @param url the url of the page
 * @param pageLoadDurationMs the duration of the page load
 * @param properties custom properties
 * @param measurements    custom metrics
 */
- (void)trackPageView:(NSString *)pageName url:(NSString *)url duration:(long)pageLoadDurationMs properties:(NSDictionary *)properties measurements:(NSDictionary *)measurements;
@end
