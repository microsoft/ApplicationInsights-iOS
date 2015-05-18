#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 *  A helper class that allows to persist and retrieve session IDs attached to different timestamps.
 */
@interface MSAIContextHelper : NSObject

@property NSUInteger appBackgroundTimeBeforeSessionExpires;

@end
NS_ASSUME_NONNULL_END
