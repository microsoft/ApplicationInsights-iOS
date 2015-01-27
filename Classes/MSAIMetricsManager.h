#import "MSAIBaseManager.h"

@class MSAIContext;
@class MSAIAppClient;

@interface MSAIMetricsManager : NSObject

///-----------------------------------------------------------------------------
/// @name Configure manager
///-----------------------------------------------------------------------------

/**
*  Prepares manager for sending out data.
*
*  @param context   the context which contains information about the device and the application.
*  @param appClient object which is needed to send out data.
*/
+ (void)configureWithContext:(MSAIContext *)context appClient:(MSAIAppClient *)appClient;

/**
 *  Enables/disables the manager.
 *
 *  @param disable determines wheteher the manager should be activated.
 */
+ (void)setDisableMetricsManager:(BOOL)disable;

/**
 *  This method should be called after the manager has been configured in order to create and send data.
 */
+ (void)startManager;

///-----------------------------------------------------------------------------
/// @name Track data
///-----------------------------------------------------------------------------

/**
 *  Track the event by event name.
 *
 *  @param eventName the name of the event, which should be tracked.
 */
+(void)trackEventWithName:(NSString *)eventName;

/**
 *  Track the event by event name and customized properties.
 *
 *  @param eventName the name of the event, which should be tracked.
 *  @param properties key value pairs with additional info about the event.
 */
+(void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties;

/**
 *  Track the event by event name and customized properties and metrics.
 *
 *  @param eventName the name of the event, which should be tracked.
 *  @param properties key value pairs with additional info about the event.
 *  @param measurements key value pairs, which contain custom metrics.
 */
+(void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties mesurements:(NSDictionary *)measurements;

/**
 *  Track by message.
 *
 *  @param message a message, which should be tracked.
 */
+(void)trackTraceWithMessage:(NSString *)message;

/**
 *  Track with the message and custom properties.
 *
 *  @param message a message, which should be tracked.
 *  @param properties key value pairs with additional info about the trace.
 */
+(void)trackTraceWithMessage:(NSString *)message properties:(NSDictionary *)properties;

/**
 *  Track metric by name and value.
 *
 *  @param metricName the name of the metric.
 *  @param value a numeric value, which should be tracked.
 */
+(void)trackMetricWithName:(NSString *)metricName value:(double)value;

/**
 *  Track metric by name and value and custom properties.
 *
 *  @param metricName the name of the metric.
 *  @param value a numeric value, which should be tracked.
 *  @param properties key value pairs with additional info about the metric.
 */
+(void)trackMetricWithName:(NSString *)metricName value:(double)value properties:(NSDictionary *)properties;

@end
