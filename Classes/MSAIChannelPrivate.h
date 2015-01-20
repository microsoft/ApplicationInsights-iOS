#import <Foundation/Foundation.h>

@class MSAIEnvelope;
@class MSAIAppClient;
@class MSAITelemetryContext;
@class MSAIAppClient;
@class MSAITelemetryContext;
@class MSAITelemetryData;

@interface MSAIChannel ()

@property(nonatomic, strong) MSAIAppClient *appClient;

@property(nonatomic, strong) MSAITelemetryContext *telemetryContext;

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
 *  Create a request for sending a data object to the telemetry server.
 *
 *  @param dataItem the data object, which should be sent to the server
 *
 *  @return a request for sending a data object to the telemetry server
 */
- (NSURLRequest *)requestForDataItem:(MSAIEnvelope *)dataItem;

/**
 *  Creates a HTTP operation and puts it to the queue.
 *
 *  @param request a request for sending a data object to the telemetry server
 */
- (void)enqueueRequest:(NSURLRequest *)request;

/**
 *  Returns the current date as string.
 *
 *  @return a string with the current date
 */
- (NSString *)dateString;

@end