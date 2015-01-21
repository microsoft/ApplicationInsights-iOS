#import "MSAISender.h"
#import "MSAIAppClient.h"
#import "MSAISenderPrivate.h"
#import "MSAIEnvelope.h"

#define defaultMaxBatchCount  10

@implementation MSAISender{
  MSAIAppClient *_appClient;
  NSString *_endpointUrl;
}

+ (instancetype)sharedSender{
  
  static MSAISender *sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [[MSAISender alloc] init];
    [sharedInstance setDataItemQueue:[NSMutableArray array]];
    
    dispatch_queue_t serialQueue = dispatch_queue_create("com.microsoft.appInsights.senderQueue", DISPATCH_QUEUE_SERIAL);
    [sharedInstance setDataItemsOperations:serialQueue];
  });
  
  return sharedInstance;
}

- (void)configureWithAppClient:(MSAIAppClient *)appClient endpointPath:(NSString *)endpointPath{
  _endpointPath = endpointPath;
  _appClient = appClient;
  
}

- (void)enqueueDataDict:(NSDictionary *)dataDict{
  
  if (dataDict) {
    dispatch_async(self.dataItemsOperations, ^{
      [_dataItemQueue addObject:dataDict];
      
      if([_dataItemQueue count] >= defaultMaxBatchCount){
        [self flushSenderQueue];
      }
    });
  }
}

- (void)flushSenderQueue{
  
  dispatch_async(self.dataItemsOperations, ^{
    
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:_dataItemQueue options:NSJSONWritingPrettyPrinted error:&error];
    NSURLRequest *request = [self requestForData:json];
    [self enqueueRequest:request];
    [_dataItemQueue removeAllObjects];
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
