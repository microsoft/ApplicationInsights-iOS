#import <Foundation/Foundation.h>
#import "MSAITelemetryData.h"

@class MSAIAppClient;
@class MSAIClientContext;

@interface MSAIChannel : NSObject

/**
 Initializes the telemetry channel with a particular instrumentation key.
 
 @param telemetrySender The sender object which sends out data items to the telemetry server
 */
- (instancetype)initWithAppClient:(MSAIAppClient *) appClient clientContext:(MSAIClientContext *)clientContext;

- (void)sendDataItem:(MSAITelemetryData *)dataItem;

@end
