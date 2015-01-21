#import <Foundation/Foundation.h>

@class MSAIEnvelope;
@class MSAITelemetryContext;
@class MSAIAppClient;
@class MSAITelemetryContext;
@class MSAITelemetryData;
@class MSAISender;

@interface MSAIChannel ()

@property(nonatomic, strong)MSAITelemetryContext *telemetryContext;

@property(nonatomic, strong)MSAISender *sender;

/**
 *  Initializes the telemetry channel.
 *
 *  @param appClient     the app client for sending data.
 *  @param clientContext information about the client and the AI account.
 *
 *  @return a channel instance.
 */
- (instancetype)initWithAppClient:(MSAIAppClient *) appClient telemetryContext:(MSAITelemetryContext *)telemetryContext;

/**
 *  Sends out telemetry data to the server.
 *
 *  @param dataItem the data object, which should be sent to the telemetry server.
 */
- (void)sendDataItem:(MSAITelemetryData *)dataItem;

/**
 *  Returns the formatted string for a given date.
 *
 *  @param date the date to be converted to a string
 *
 *  @return the string representation for a given date
 */
- (NSString *)dateStringForDate:(NSDate *)date;

@end
