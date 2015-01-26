#import "MSAISender.h"
#import "MSAIAppClient.h"
#import "MSAISenderPrivate.h"
#import "MSAIEnvelope.h"

static NSInteger const defaultMaxBatchCount = 5;
static NSInteger const defaultBatchInterval = 15;

@implementation MSAISender

@synthesize dataItemQueue = _dataItemQueue;

+ (instancetype)sharedSender{
  
  static MSAISender *sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [[MSAISender alloc] init];
    dispatch_queue_t serialQueue = dispatch_queue_create("com.microsoft.appInsights.senderQueue", DISPATCH_QUEUE_SERIAL);
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
        dispatch_async(dispatch_get_main_queue(), ^{
          [strongSelf invalidateTimerAndRestart:NO];
        });
        [strongSelf flushSenderQueue];
      }else if([strongSelf->_dataItemQueue count] == 1){
        dispatch_async(dispatch_get_main_queue(), ^{
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
                                            selector:@selector(flushSenderQueue)
                                            userInfo: nil repeats:NO];
  }
}

- (void)flushSenderQueue{
  
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.dataItemsOperations, ^{
    typeof(self) strongSelf = weakSelf;
    
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:strongSelf->_dataItemQueue options:NSJSONWritingPrettyPrinted error:&error];
    NSURLRequest *request = [strongSelf requestForData:json];
    [strongSelf enqueueRequest:request];
    [strongSelf->_dataItemQueue removeAllObjects];
  });
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
