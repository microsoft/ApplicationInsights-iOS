#import "MSAIChannel.h"
#import "MSAIChannelPrivate.h"
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAIEnvelope.h"
#import "MSAIHTTPOperation.h"
#import "MSAIAppClient.h"
#import "AppInsightsPrivate.h"
#import "MSAIData.h"
#import "MSAISender.h"
#import "MSAISenderPrivate.h"
#import "MSAIHelper.h"
#import "MSAIPersistence.h"

#ifdef DEBUG
static NSInteger const defaultMaxBatchCount = 50;
static NSInteger const defaultBatchInterval = 15;
#else
static NSInteger const defaultMaxBatchCount = 50;
static NSInteger const defaultBatchInterval = 15;
#endif

static char *const MSAIDataItemsOperationsQueue = "com.microsoft.appInsights.senderQueue";

@implementation MSAIChannel

#pragma mark - Initialisation

+ (id)sharedChannel {
  static MSAIChannel *sharedChannel = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedChannel = [self new];
    dispatch_queue_t serialQueue = dispatch_queue_create(MSAIDataItemsOperationsQueue, DISPATCH_QUEUE_SERIAL);
    [sharedChannel setDataItemsOperations:serialQueue];
  });
  
  return sharedChannel;
}

- (instancetype)init {
  if(self = [super init]) {
    self.dataItemQueue = [NSMutableArray array];
    self.senderBatchSize = defaultMaxBatchCount;
    self.senderInterval = defaultBatchInterval;
  }
  return self;
}

#pragma mark - Queue management

- (void)enqueueDictionary:(MSAIOrderedDictionary *)dictionary{
  if(dictionary) {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.dataItemsOperations, ^{
      typeof(self) strongSelf = weakSelf;
      
      // Enqueue item
      [strongSelf->_dataItemQueue addObject:dictionary];
      
      if([strongSelf->_dataItemQueue count] >= strongSelf.senderBatchSize) {
        
        // Max batch count has been reached, so write queue to disk and delete all items.
        [strongSelf invalidateTimer];
        NSArray *bundle = [NSArray arrayWithArray:strongSelf->_dataItemQueue];
        [[MSAIPersistence sharedInstance] persistBundle:bundle ofType:MSAIPersistenceTypeRegular withCompletionBlock:nil];
        [strongSelf->_dataItemQueue removeAllObjects];
      } else if([strongSelf->_dataItemQueue count] == 1) {
        
        // It is the first item, let's start the timer
        [strongSelf startTimer];
      }
    });
  }
}

- (void)processDictionary:(MSAIOrderedDictionary *)dictionary withCompletionBlock: (void (^)(BOOL success)) completionBlock{
  [[MSAIPersistence sharedInstance] persistBundle:[NSArray arrayWithObject:dictionary]
                          ofType:MSAIPersistenceTypeHighPriority withCompletionBlock:completionBlock];
}

- (NSMutableArray *)dataItemQueue {
  __block NSMutableArray *queue = nil;
  __weak typeof(self) weakSelf = self;
  dispatch_sync(self.dataItemsOperations, ^{
    typeof(self) strongSelf = weakSelf;
    
    queue = [NSMutableArray arrayWithArray:strongSelf->_dataItemQueue];
  });
  return queue;
}

- (BOOL)isQueueBusy{
  return ![[MSAIPersistence sharedInstance] isFreeSpaceAvailable];
}

#pragma mark - Batching

- (void)invalidateTimer {
  if(self.timerSource) {
    dispatch_source_cancel(self.timerSource);
    self.timerSource = nil;
  }
}

- (void)startTimer {

  // Reset timer, if it is already running
  if(self.timerSource) {
    [self invalidateTimer];
  }

  self.timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.dataItemsOperations);
  dispatch_source_set_timer(self.timerSource, dispatch_walltime(NULL, NSEC_PER_SEC * self.senderInterval), 1ull * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
  dispatch_source_set_event_handler(self.timerSource, ^{
    
    // On completion: Reset timer and persist items
    [self invalidateTimer];
    [self persistQueue];
  });
  dispatch_resume(self.timerSource);
}

- (void)persistQueue {
  NSArray *bundle = [NSArray arrayWithArray:_dataItemQueue];
  [[MSAIPersistence sharedInstance] persistBundle:bundle ofType:MSAIPersistenceTypeRegular withCompletionBlock:nil];
  [_dataItemQueue removeAllObjects];
}

@end
