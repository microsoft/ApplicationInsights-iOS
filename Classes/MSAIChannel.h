#import <Foundation/Foundation.h>
#import "MSAITelemetryData.h"

@class MSAIAppClient;
@class MSAIClientContext;

@interface MSAIChannel : NSObject

/**
 *  Initializes the telemetry channel.
 *
 *  @param appClient     the app client for sending data.
 *  @param clientContext information about the client and the AI account.
 *
 *  @return a channel instance.
 */
- (instancetype)initWithAppClient:(MSAIAppClient *) appClient clientContext:(MSAIClientContext *)clientContext;

/**
 *  Sends out telemetry data to the server.
 *
 *  @param dataItem the data object, which should be sent to the telemetry server.
 */
- (void)sendDataItem:(MSAITelemetryData *)dataItem;

@end
