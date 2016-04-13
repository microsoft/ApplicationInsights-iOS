#import <Foundation/Foundation.h>
#import "MSAINullability.h"
#import "MSAIDevice.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const kMSAIApplicationWasLaunched;

/**
 *  Context object which contains information about the device, user, session etc.
 */
@interface MSAITelemetryContext : NSObject

/**
 *  The device context.
 */
@property (nonatomic, strong, readonly)MSAIDevice *device;

@end
NS_ASSUME_NONNULL_END
