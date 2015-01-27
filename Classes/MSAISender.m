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

@synthesize dataItemQueue = _dataItemQueue;

+ (instancetype)sharedSender{
  
  static MSAISender *sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [[MSAISender alloc] init];
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

- (void)enqueueDataDict:(NSDictionary *)dataDict{
  
  if (dataDict) {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.dataItemsOperations, ^{
      typeof(self) strongSelf = weakSelf;
      
      [strongSelf->_dataItemQueue addObject:dataDict];
      
      if([strongSelf->_dataItemQueue count] >= defaultMaxBatchCount){
        dispatch_sync(dispatch_get_main_queue(), ^{
          [strongSelf invalidateTimerAndRestart:NO];
        });
        [strongSelf flushSenderQueue];
      }else if([strongSelf->_dataItemQueue count] == 1){
        dispatch_sync(dispatch_get_main_queue(), ^{
          [strongSelf invalidateTimerAndRestart:YES];
        });
      }
    });
  }
}

- (NSMutableArray *)dataItemQueue{
  
  __block NSMutableArray *queue = nil;
  __weak typeof(self) weakSelf = self;
  dispatch_sync(self.dataItemsOperations, ^{
    typeof(self) strongSelf = weakSelf;
    
    queue = [NSMutableArray arrayWithArray:strongSelf->_dataItemQueue];
  });
  return queue;
}

- (void)invalidateTimerAndRestart:(BOOL)restart{
  if(_timer){
    [_timer invalidate];
    _timer = nil;
  }
  
  if(restart){
    _timer = [NSTimer scheduledTimerWithTimeInterval:defaultBatchInterval
                                              target: self
                                            selector:@selector(timerFinished)
                                            userInfo: nil repeats:NO];
  }
}

- (void)timerFinished{
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.dataItemsOperations, ^{
    typeof(self) strongSelf = weakSelf;
    [strongSelf flushSenderQueue];
  });
}

- (void)flushSenderQueue{
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:_dataItemQueue options:NSJSONWritingPrettyPrinted error:&error];
    NSURLRequest *request = [self requestForData:json];
    [self enqueueRequest:request];
    [_dataItemQueue removeAllObjects];
}

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

- (void)enqueueRequest:(NSURLRequest *)request{
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

@end
