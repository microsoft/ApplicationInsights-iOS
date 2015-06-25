#import <Foundation/Foundation.h>
#import "MSAINullability.h"

NS_ASSUME_NONNULL_BEGIN
/**
 * Utility class that's responsible for sending a bundle of data to the server
 */
@interface MSAISender : NSObject

/**
 *  Triggers sending the saved data. Does nothing if nothing has been persisted, yet. This method should be called by MSAITelemetryManager on app start.
 */
- (void)sendSavedData;

@end
NS_ASSUME_NONNULL_END
