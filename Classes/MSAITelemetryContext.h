#import <Foundation/Foundation.h>
#import "ApplicationInsights.h"

FOUNDATION_EXPORT NSString *const kMSAIApplicationWasLaunched;

MSAI_ASSUME_NONNULL_BEGIN
/**
 *  Context object which contains information about the device, user, session etc.
 */
@interface MSAITelemetryContext : NSObject

@end
MSAI_ASSUME_NONNULL_END
