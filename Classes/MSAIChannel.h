#import <Foundation/Foundation.h>
#import "MSAINullability.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT char *MSAISafeJsonEventsString;

/**
 *  Prepares telemetry data and forwards it to the persistence layer. Once data has been persisted it will be sent by the sender automatically.
 */
@interface MSAIChannel : NSObject

@end
NS_ASSUME_NONNULL_END
