#import <Foundation/Foundation.h>
#import "ApplicationInsights.h"

extern NSString *const kMSAIApplicationWasLaunched;

NS_ASSUME_NONNULL_BEGIN
/**
 *  Context object which contains information about the device, user, session etc.
 */
@interface MSAITelemetryContext : NSObject

@end
NS_ASSUME_NONNULL_END
