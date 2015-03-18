#import <Foundation/Foundation.h>

@interface MSAISessionHelper()

/**
 *  A serial queue which makes makes insert/remove operations thread safe.
 */
@property (nonatomic, strong) dispatch_queue_t operationsQueue;

/**
 *  A Dictionary which holds content of property list in memory.
 */
@property (nonatomic, strong) NSMutableDictionary *sessionEntries;

/**
 *  Returns the shared instance.
 *
 *  @return the shared instance
 */
+ (id)sharedInstance;

@end
