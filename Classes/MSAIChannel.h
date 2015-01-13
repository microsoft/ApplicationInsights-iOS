#import <Foundation/Foundation.h>
#import "MSAITelemetryData.h"

@class MSAISender;
@class MSAIClientConfig;

@interface MSAIChannel : NSObject

/**
 Initializes the telemetry channel with a particular instrumentation key.
 
 @param telemetrySender The sender object which sends out data items to the telemetry server
 */
- (instancetype)initWithClientConfig:(MSAIClientConfig *)clientConfig;

- (void)sendDataItem:(MSAITelemetryData *)dataItem;

@end
