#import <Foundation/Foundation.h>
#import "MSAINullability.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSAIConfiguration : NSObject

/**
 *  The server URL to which data will be sent.
 */
@property (nonatomic, copy) NSString *serverURL;

/**
 *  The background time of the app, after which a new session will be automatically started.
 */
@property (nonatomic, assign) NSUInteger backgroundSessionInterval;

/**
 *  The maximum number of items after which the queue content gets sent out.
 */
@property (nonatomic, assign) NSUInteger maxBatchCount;

/**
 *  The maximum time interval after which the queue content gets sent out.
 */
@property (nonatomic, assign) NSUInteger maxBatchInterval;

@end
NS_ASSUME_NONNULL_END
