#import <Foundation/Foundation.h>
#import "MSAITelemetryData.h"

@class MSAIAppClient;
@class MSAITelemetryContext;

@interface MSAIChannel : NSObject

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

@end
