#import "MSAIChannel.h"
#import "MSAIChannelPrivate.h"
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAIEnvelope.h"
#import "MSAIHTTPOperation.h"
#import "MSAIAppClient.h"
#import "ApplicationInsightsPrivate.h"
#import "MSAIData.h"
#import "MSAISender.h"
#import "MSAISenderPrivate.h"
#import "MSAIHelper.h"
#import "MSAIPersistence.h"

NSInteger const defaultMaxBatchCount = 50;
NSInteger const defaultBatchInterval = 15;

NSInteger const debugMaxBatchCount = 5;
NSInteger const debugBatchInterval = 3;

static char *const MSAIDataItemsOperationsQueue = "com.microsoft.ApplicationInsights.senderQueue";
char *MSAISafeJsonEventsString;

@implementation MSAIChannel

static MSAIChannel *_sharedChannel = nil;
static dispatch_once_t once_token;

#pragma mark - Initialisation

+ (id)sharedChannel {
  
  dispatch_once(&once_token, ^{
    if (_sharedChannel == nil) {
      _sharedChannel = [self new];
    }
  });
  return _sharedChannel;
}

+(void)setSharedChannel:(MSAIChannel *)channel {
  once_token = 0;
  _sharedChannel = channel;
}

- (instancetype)init {
  if(self = [super init]) {
    _dataItemQueue = [NSMutableArray array];
    if (msai_isDebuggerAttached()) {
      _senderBatchSize = debugMaxBatchCount;
      _senderInterval = debugBatchInterval;
    } else {
      _senderBatchSize = defaultMaxBatchCount;
      _senderInterval = defaultBatchInterval;
    }
    dispatch_queue_t serialQueue = dispatch_queue_create(MSAIDataItemsOperationsQueue, DISPATCH_QUEUE_SERIAL);
    _dataItemsOperations = serialQueue;
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
      [strongSelf addDictionaryToQueues:dictionary];

      if([strongSelf->_dataItemQueue count] >= strongSelf.senderBatchSize) {
        
        // Max batch count has been reached, so write queue to disk and delete all items.
        [strongSelf persistDataItemQueue];
      } else if([strongSelf->_dataItemQueue count] == 1) {
        
        // It is the first item, let's start the timer
        [strongSelf startTimer];
      }
    });
  }
}

- (void)addDictionaryToQueues:(MSAIOrderedDictionary *)dictionary {
  // Since we can't persist every event right away, we write it to a simple C string.
  // This can then be written to disk by a signal handler in case of a crash.
  [self->_dataItemQueue addObject:dictionary];
  msai_appendDictionaryToSafeJsonString(dictionary, &(MSAISafeJsonEventsString));
}

void msai_appendDictionaryToSafeJsonString(NSDictionary *dictionary, char **string) {
  if (string == NULL) { return; }

  if (!dictionary) { return; }
  
  if (*string == NULL || strlen(*string) == 0) {
    msai_resetSafeJsonString(string);
  }

  NSError *error = nil;
  NSData *json_data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
  if (!json_data) {
    MSAILog(@"JSONSerialization error: %@", error.description);
    return;
  }

  char *new_string = NULL;
  // Concatenate old string with new JSON string and add a comma.
  asprintf(&new_string, "%s%.*s,", *string, (int)MIN(json_data.length, (NSUInteger)INT_MAX), json_data.bytes);
  free(*string);
  *string = new_string;
}

void msai_resetSafeJsonString(char **string) {
  if (!string) { return; }
  free(*string);
  *string = strdup("[");
}

- (void)processDictionary:(MSAIOrderedDictionary *)dictionary withCompletionBlock: (nullable void (^)(BOOL success)) completionBlock{
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

- (void)persistDataItemQueue {
  [self invalidateTimer];
  NSArray *bundle = [NSArray arrayWithArray:_dataItemQueue];
  [[MSAIPersistence sharedInstance] persistBundle:bundle ofType:MSAIPersistenceTypeRegular withCompletionBlock:nil];
  
  // Reset both, the async-signal-safe and normal queue.
  [_dataItemQueue removeAllObjects];
  msai_resetSafeJsonString(&(MSAISafeJsonEventsString));
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
    [self persistDataItemQueue];
  });
  dispatch_resume(self.timerSource);
}

@end
