//
// Created by Benjamin Reimold on 03.02.15.
//

#import "MSAIPersistence.h"


@implementation MSAIPersistence

#pragma mark - Public

+ (void)persistQueue:(NSArray *)queue {

  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:queue];

  dispatch_queue_t backgroundQueue =
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

  dispatch_async(backgroundQueue, ^{
    [data writeToFile:[self queueURL]  atomically:YES];
  });

}

+ (void)readPersistedQueue {

}

#pragma mark - Private


+ (NSString *)queueURL  {
  return @"";
}

@end