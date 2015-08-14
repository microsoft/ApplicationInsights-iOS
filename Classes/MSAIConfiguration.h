#import <Foundation/Foundation.h>
#import "MSAINullability.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSAIConfiguration : NSObject

/**
 *  A queue which makes array operations thread safe.
 */
@property (nonatomic, strong) dispatch_queue_t operationsQueue;

/**
 *  The server URL to which data will be sent.
 */
@property (nonatomic, copy) NSURL *serverURL;

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
