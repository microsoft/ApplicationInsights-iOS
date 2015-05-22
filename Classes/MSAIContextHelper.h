#import <Foundation/Foundation.h>

MSAI_ASSUME_NONNULL_BEGIN
/**
 *  A helper class that allows to persist and retrieve session IDs attached to different timestamps.
 */
@interface MSAIContextHelper : NSObject

@property NSUInteger appBackgroundTimeBeforeSessionExpires;

@end
MSAI_ASSUME_NONNULL_END
