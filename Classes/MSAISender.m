#import "MSAISender.h"
#import "MSAIAppClient.h"
#import "MSAISenderPrivate.h"
#import "MSAIEnvelope.h"

#ifdef DEBUG
static NSInteger const defaultMaxBatchCount = 150;
static NSInteger const defaultBatchInterval = 15;
#else
static NSInteger const defaultMaxBatchCount = 5;
static NSInteger const defaultBatchInterval = 15;
#endif

static char *const MSAIDataItemsOperationsQueue = "com.microsoft.appInsights.senderQueue";

@implementation MSAISender

#pragma mark - Initialize & configure shared instance

+ (instancetype)sharedSender{
  static MSAISender *sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [MSAISender new];
    dispatch_queue_t serialQueue = dispatch_queue_create(MSAIDataItemsOperationsQueue, DISPATCH_QUEUE_SERIAL);
    [sharedInstance setDataItemsOperations:serialQueue];
  });
  return sharedInstance;
}

- (instancetype)init{
  if(self = [super init]){
    _dataItemQueue = [NSMutableArray array];
  }
  return self;
}

- (void)configureWithAppClient:(MSAIAppClient *)appClient endpointPath:(NSString *)endpointPath{
  _endpointPath = endpointPath;
  _appClient = appClient;
}

#pragma mark - Queue management

- (NSMutableArray *)dataItemQueue{
  
  __block NSMutableArray *queue = nil;
  __weak typeof(self) weakSelf = self;
  dispatch_sync(self.dataItemsOperations, ^{
    typeof(self) strongSelf = weakSelf;
    
    queue = [NSMutableArray arrayWithArray:strongSelf->_dataItemQueue];
  });
  return queue;
}

- (void)enqueueDataDict:(NSDictionary *)dataDict{
  
  if (dataDict) {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.dataItemsOperations, ^{
      typeof(self) strongSelf = weakSelf;
      
      [strongSelf->_dataItemQueue addObject:dataDict];
      
      if([strongSelf->_dataItemQueue count] >= defaultMaxBatchCount){
        [strongSelf invalidateTimer];
        [strongSelf flushSenderQueue];
      }else if([strongSelf->_dataItemQueue count] == 1){
        [strongSelf startTimer];
      }
    });
  }
}

#pragma mark - Batching

- (void)invalidateTimer{
  if(self.timerSource){
    dispatch_source_cancel(self.timerSource);
    self.timerSource = nil;
  }
}

- (void)startTimer {
  
  if(self.timerSource){
    [self invalidateTimer];
  }
  
  self.timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.dataItemsOperations);
  dispatch_source_set_timer(self.timerSource, dispatch_walltime(NULL, NSEC_PER_SEC * defaultBatchInterval), 1ull * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
  dispatch_source_set_event_handler(self.timerSource, ^{
    [self invalidateTimer];
    [self flushSenderQueue];
  });
  dispatch_resume(self.timerSource);
}

- (void)flushSenderQueue{
  NSError *error = nil;
  NSData *json = [NSJSONSerialization dataWithJSONObject:_dataItemQueue options:NSJSONWritingPrettyPrinted error:&error];
  NSURLRequest *request = [self requestForData:json];
  [self sendRequest:request];
  [_dataItemQueue removeAllObjects];
}

- (void)sendRequest:(NSURLRequest *)request{
  MSAIHTTPOperation *operation = [_appClient
                                  operationWithURLRequest:request
                                  completion:^(MSAIHTTPOperation *operation, NSData* responseData, NSError *error) {
                                    
                                    NSInteger statusCode = [operation.response statusCode];
                                    
                                    if (nil == error) {
                                      if (nil == responseData || [responseData length] == 0) {
                                        NSLog(@"Sending failed with an empty response!");
                                      } else{
                                        NSLog(@"Sent data with status code: %ld", (long)statusCode);
                                        NSLog(@"Response data:\n%@", [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil]);
                                      }
                                    }else{
                                      NSLog(@"Sending failed");
                                    }
                                  }];
  
  [_appClient enqeueHTTPOperation:operation];
}

#pragma mark - Helper

- (NSURLRequest *)requestForData:(NSData *)data{
  NSMutableURLRequest *request = [_appClient requestWithMethod:@"POST"
                                                          path:_endpointPath
                                                    parameters:nil];
  
  [request setHTTPBody:data];
  [request setCachePolicy: NSURLRequestReloadIgnoringLocalCacheData];
  NSString *contentType = @"application/json";
  [request setValue:contentType forHTTPHeaderField:@"Content-type"];
  return request;
}

@end
