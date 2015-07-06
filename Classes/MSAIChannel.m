#import "MSAIChannel.h"
#import "MSAIChannelPrivate.h"
#import "MSAITelemetryContextPrivate.h"
#import "ApplicationInsightsPrivate.h"
#import "MSAIHelper.h"
#import "MSAIPersistencePrivate.h"

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

+ (instancetype)sharedChannel {
  
  dispatch_once(&once_token, ^{
    if (_sharedChannel == nil) {
      _sharedChannel = [self new];
    }
  });
  return _sharedChannel;
}

+ (void)setSharedChannel:(MSAIChannel *)channel {
  once_token = 0;
  _sharedChannel = channel;
}

- (instancetype)init {
  if(self = [super init]) {
    msai_resetSafeJsonStream(&MSAISafeJsonEventsString);
    _dataItemCount = 0;
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

- (BOOL)isQueueBusy{
  return ![[MSAIPersistence sharedInstance] isFreeSpaceAvailable];
}

- (void)persistDataItemQueue {
  [self invalidateTimer];
  if(!MSAISafeJsonEventsString || strlen(MSAISafeJsonEventsString) == 0) {
    return;
  }
  
  NSData *bundle = [NSData dataWithBytes:MSAISafeJsonEventsString length:strlen(MSAISafeJsonEventsString)];
  [[MSAIPersistence sharedInstance] persistBundle:bundle ofType:MSAIPersistenceTypeRegular withCompletionBlock:nil];
  
  // Reset both, the async-signal-safe and item counter.
  [self resetQueue];
}

- (void)resetQueue {
  msai_resetSafeJsonStream(&MSAISafeJsonEventsString);
  _dataItemCount = 0;
}

#pragma mark - Adding to queue

- (void)enqueueDictionary:(MSAIOrderedDictionary *)dictionary {
  if(dictionary) {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.dataItemsOperations, ^{
      typeof(self) strongSelf = weakSelf;
      
      // Enqueue item
      [strongSelf appendDictionaryToJsonStream:dictionary];
      
      if(strongSelf->_dataItemCount >= strongSelf.senderBatchSize) {
        // Max batch count has been reached, so write queue to disk and delete all items.
        [strongSelf persistDataItemQueue];
        
      } else if(strongSelf->_dataItemCount == 1) {
        // It is the first item, let's start the timer
        [strongSelf startTimer];
      }
    });
  }
}

- (void)processDictionary:(MSAIOrderedDictionary *)dictionary withCompletionBlock: (nullable void (^)(BOOL success)) completionBlock{
  [[MSAIPersistence sharedInstance] persistBundle:[self serializeObjectToJSONData:dictionary]
                                           ofType:MSAIPersistenceTypeHighPriority withCompletionBlock:completionBlock];
}

#pragma mark - Serialization Helper

- (NSString *)serializeDictionaryToJSONString:(MSAIOrderedDictionary *)dictionary {
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:(NSJSONWritingOptions)0 error:&error];
  if (!data) {
    MSAILog(@"JSONSerialization error: %@", error.localizedDescription);
    return @"{}";
  } else {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  }
}

- (NSData *)serializeObjectToJSONData:(id)object {
  NSError *error = nil;
  NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
  if (!data) {
    MSAILog(@"JSONSerialization error: %@", error.localizedDescription);
    return nil;
  }
  return data;
}

#pragma mark JSON Stream

- (void)appendDictionaryToJsonStream:(MSAIOrderedDictionary *)dictionary {
  NSString *string = [self serializeDictionaryToJSONString:dictionary];
  
  // Since we can't persist every event right away, we write it to a simple C string.
  // This can then be written to disk by a signal handler in case of a crash.
  msai_appendStringToSafeJsonStream(string, &(MSAISafeJsonEventsString));
  _dataItemCount += 1;
}

void msai_appendStringToSafeJsonStream(NSString *string, char **jsonString) {
  if (jsonString == NULL) { return; }
  
  if (!string) { return; }
  
  if (*jsonString == NULL || strlen(*jsonString) == 0) {
    msai_resetSafeJsonStream(jsonString);
  }
  
  if (string.length == 0) { return; }
  
  char *new_string = NULL;
  // Concatenate old string with new JSON string and add a comma.
  asprintf(&new_string, "%s%.*s\n", *jsonString, (int)MIN(string.length, (NSUInteger)INT_MAX), string.UTF8String);
  free(*jsonString);
  *jsonString = new_string;
}

void msai_resetSafeJsonStream(char **string) {
  if (!string) { return; }
  free(*string);
  *string = strdup("");
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
