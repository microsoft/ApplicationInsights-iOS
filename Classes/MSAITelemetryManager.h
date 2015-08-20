#import <Foundation/Foundation.h>
#import "ApplicationInsights.h"

#if MSAI_FEATURE_TELEMETRY

NS_ASSUME_NONNULL_BEGIN
/**
* MSAITelemetryManager is the component of the Application Insights SDK for iOS that is responsible for all things
* that are related to metrics and tracking.
* It provides methods to track custom events, traces, metrics, pageviews and exceptions. You can access them via
* class methods as well as via the sharedManager instance.
*/
@interface MSAITelemetryManager : NSObject

///-----------------------------------------------------------------------------
/// @name Configure manager
///-----------------------------------------------------------------------------

/**
*  Returns the shared MSAITelemetryManager instance.
*
*  @return the shared instance
*/
+ (instancetype)sharedManager;

///-----------------------------------------------------------------------------
/// @name Common Properties
///-----------------------------------------------------------------------------

/**
 *  Set any dictionary of key-value pairs which will then be attached to every telemetry item that is sent.
 *
 *  @param commonProperties The dictionary containing the key-value pairs.
 *  
 *  @warning All of the values in this dictionary have to be NSJSONSerialization compatible!
 */
+ (void)setCommonProperties:(NSDictionary *)commonProperties;

/**
 *  The dictionary of key-value pares that will be attached to every telemetry item.
 *
 *  @warning All of the values in this dictionary have to be NSJSONSerialization compatible!
 */
@property (nonatomic, strong) NSDictionary *commonProperties;

///-----------------------------------------------------------------------------
/// @name Track data
///-----------------------------------------------------------------------------

/**
 *  Track the event by event name.
 *
 *  @param eventName The name of the event, which should be tracked.
 */
+ (void)trackEventWithName:(NSString *)eventName;

/**
 *  Track the event by event name and customized properties.
 *
 *  @param eventName The name of the event, which should be tracked.
 *  @param properties Key-value pairs with additional info about the event.
 */
+ (void)trackEventWithName:(NSString *)eventName properties:(nullable NSDictionary *)properties;

/**
 *  Track the event by event name and customized properties and metrics.
 *
 *  @param eventName The name of the event, which should be tracked.
 *  @param properties Key-value pairs with additional info about the event.
 *  @param measurements Key-value pairs, which contain custom metrics.
 */
+ (void)trackEventWithName:(NSString *)eventName properties:(nullable NSDictionary *)properties measurements:(nullable NSDictionary *)measurements;

/**
 *  Track by message.
 *
 *  @param message A message, which should be tracked.
 */
+ (void)trackTraceWithMessage:(NSString *)message;

/**
 *  Track with the message and custom properties.
 *
 *  @param message A message, which should be tracked.
 *  @param properties Key-value pairs with additional info about the trace.
 */
+ (void)trackTraceWithMessage:(NSString *)message properties:(nullable NSDictionary *)properties;

/**
 *  Track metric by name and value.
 *
 *  @param metricName The name of the metric.
 *  @param value A numeric value, which should be tracked.
 */
+ (void)trackMetricWithName:(NSString *)metricName value:(double)value;

/**
 *  Track metric by name and value and custom properties.
 *
 *  @param metricName The name of the metric.
 *  @param value A numeric value, which should be tracked.
 *  @param properties Key-value pairs with additional info about the metric.
 */
+ (void)trackMetricWithName:(NSString *)metricName value:(double)value properties:(nullable NSDictionary *)properties;

/**
 * Track pageView by name of the page.
 *
 *  @deprecated Use `MSAITelemetryManager trackPageViewWithName:' instead
 *  @param pageName Name of the page/view which is being tracked.
 */
+ (void)trackPageView:(NSString *)pageName DEPRECATED_MSG_ATTRIBUTE("Use `MSAITelemetryManager trackPageViewWithName:' instead");

/**
 *  Track pageView by name of the page.
 *
 *  @deprecated Use `MSAITelemetryManager trackPageViewWithName:' instead
 *  @param pageName Name of the page/view which is being tracked.
 *  @param duration Time the page has been viewed in milliseconds. This method is ideally called when a page view ends where the time has to be calculated by the developer.
 */
+ (void)trackPageView:(NSString *)pageName duration:(long)duration DEPRECATED_MSG_ATTRIBUTE("Use `MSAITelemetryManager trackPageViewWithName:' instead");

/**
 * Track pageView by name of the page.
 *
 *  @deprecated Use `MSAITelemetryManager trackPageViewWithName:properties:' instead
 *  @param pageName Name of the page/view which is being tracked.
 *  @param duration Time the page has been viewed. This method is ideally called when a page view ends. The time has to be calculated by the developer.
 *  @param properties Key-Value pairs which can contain additional information about the page view.
 */
+ (void)trackPageView:(NSString *)pageName duration:(long)duration properties:(nullable NSDictionary *)properties DEPRECATED_MSG_ATTRIBUTE("Use `MSAITelemetryManager trackPageViewWithName:properties:' instead");

/**
 * Track pageView by name of the page.
 *
 *  @param pageName Name of the page/view which is being tracked.
 */
+ (void)trackPageViewWithName:(NSString *)pageName;

/**
 * Track pageView by name of the page.
 *
 *  @param pageName Name of the page/view which is being tracked.
 *  @param properties Key-value pairs which can contain additional information about the page view.
 */
+ (void)trackPageViewWithName:(NSString *)pageName properties:(nullable NSDictionary *)properties;

/**
 * Track pageView by name of the page.
 *
 *  @param pageName Name of the page/view which is being tracked.
 *  @param properties Key-value pairs which can contain additional information about the page view.
 *  @param measurements Key-value pairs, which contain custom metrics.
 */
+ (void)trackPageViewWithName:(NSString *)pageName properties:(nullable NSDictionary *)properties measurements:(nullable NSDictionary *)measurements;

/**
 *  Track handled exception.
 *
 *  @param exception The handled exception, which should be send to the server.
 */
+ (void)trackException:(NSException *)exception;

/**
 *  Track handled exception.
 *
 *  @param exception The handled exception, which should be send to the server.
 *  @param properties Key-value pairs with additional info about the metric.
 */
+ (void)trackException:(NSException *)exception properties:(nullable NSDictionary *)properties;

/**
 *  Track handled exception.
 *
 *  @param exception The handled exception, which should be send to the server.
 *  @param properties Key-value pairs with additional info about the metric.
 *  @param measurements Key-value pairs, which contain custom metrics.
 */
+ (void)trackException:(NSException *)exception properties:(nullable NSDictionary *)properties measurements:(nullable NSDictionary *)measurements;

/**
 *  Track the event by event name.
 *
 *  @param eventName The name of the event, which should be tracked.
 */
- (void)trackEventWithName:(NSString *)eventName;

/**
 *  Track the event by event name and customized properties.
 *
 *  @param eventName The name of the event, which should be tracked.
 *  @param properties Key-value pairs with additional info about the event.
 */
- (void)trackEventWithName:(NSString *)eventName properties:(nullable NSDictionary *)properties;

/**
 *  Track the event by event name and customized properties and metrics.
 *
 *  @param eventName The name of the event, which should be tracked.
 *  @param properties Key-value pairs with additional info about the event.
 *  @param measurements key-value pairs, which contain custom metrics.
 */
- (void)trackEventWithName:(NSString *)eventName properties:(nullable NSDictionary *)properties measurements:(nullable NSDictionary *)measurements;

/**
 *  Track by message.
 *
 *  @param message A message, which should be tracked.
 */
- (void)trackTraceWithMessage:(NSString *)message;

/**
 *  Track with the message and custom properties.
 *
 *  @param message A message, which should be tracked.
 *  @param properties Key-value pairs with additional info about the trace.
 */
- (void)trackTraceWithMessage:(NSString *)message properties:(nullable NSDictionary *)properties;

/**
 *  Track metric by name and value.
 *
 *  @param metricName The name of the metric.
 *  @param value A numeric value, which should be tracked.
 */
- (void)trackMetricWithName:(NSString *)metricName value:(double)value;

/**
 *  Track metric by name and value and custom properties.
 *
 *  @param metricName The name of the metric.
 *  @param value A numeric value, which should be tracked.
 *  @param properties Key-value pairs with additional info about the metric.
 */
- (void)trackMetricWithName:(NSString *)metricName value:(double)value properties:(nullable NSDictionary *)properties;

/**
 * Track pageView by name of the page.
 *
 *  @deprecated Use `MSAITelemetryManager trackPageViewWithName:' instead
 *  @param pageName Name of the page/view which is being tracked.
 */
- (void)trackPageView:(NSString *)pageName DEPRECATED_MSG_ATTRIBUTE("Use `MSAITelemetryManager trackPageViewWithName:' instead");

/**
 *  Track pageView by name of the page.
 *
 *  @deprecated Use `MSAITelemetryManager trackPageViewWithName:' instead
 *  @param pageName Name of the page/view which is being tracked.
 *  @param duration Time the page has been viewed in milliseconds. This method is ideally called when a page view ends where the time has to be calculated by the developer.
 */
- (void)trackPageView:(NSString *)pageName duration:(long)duration DEPRECATED_MSG_ATTRIBUTE("Use `MSAITelemetryManager trackPageViewWithName:' instead");

/**
 * Track pageView by name of the page.
 *
 *  @deprecated Use `MSAITelemetryManager trackPageViewWithName:properties:' instead
 *  @param pageName Name of the page/view which is being tracked.
 *  @param duration Time the page has been viewed. This method is ideally called when a page view ends. The time has to be calculated by the developer.
 *  @param properties Key-value pairs which can contain additional information about the page view.
 */
- (void)trackPageView:(NSString *)pageName duration:(long)duration properties:(nullable NSDictionary *)properties DEPRECATED_MSG_ATTRIBUTE("Use `MSAITelemetryManager trackPageViewWithName:properties:' instead");

/**
 * Track pageView by name of the page.
 *
 *  @param pageName Name of the page/view which is being tracked.
 */
- (void)trackPageViewWithName:(NSString *)pageName;

/**
 * Track pageView by name of the page.
 *
 *  @param pageName Name of the page/view which is being tracked.
 *  @param properties Key-value pairs which can contain additional information about the page view.
 */
- (void)trackPageViewWithName:(NSString *)pageName properties:(nullable NSDictionary *)properties;

/**
 * Track pageView by name of the page.
 *
 *  @param pageName Name of the page/view which is being tracked.
 *  @param properties Key-value pairs which can contain additional information about the page view.
 *  @param measurements key-value pairs, which contain custom metrics.
 */
- (void)trackPageViewWithName:(NSString *)pageName properties:(nullable NSDictionary *)properties measurements:(nullable NSDictionary *)measurements;

/**
 *  Track handled exception.
 *
 *  @param exception The handled exception, which should be send to the server.
 */
- (void)trackException:(NSException *)exception;

/**
 *  Track handled exception.
 *
 *  @param exception The handled exception, which should be send to the server.
 *  @param properties Key-value pairs with additional info about the metric.
 */
- (void)trackException:(NSException *)exception properties:(nullable NSDictionary *)properties;

/**
 *  Track handled exception.
 *
 *  @param exception The handled exception, which should be send to the server.
 *  @param properties Key-value pairs with additional info about the metric.
 *  @param measurements key-value pairs, which contain custom metrics.
 */
- (void)trackException:(NSException *)exception properties:(nullable NSDictionary *)properties measurements:(nullable NSDictionary *)measurements;

@end
NS_ASSUME_NONNULL_END

#endif /* MSAI_FEATURE_TELEMETY */
