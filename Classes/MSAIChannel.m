#import "MSAIChannel.h"
#import "MSAIClientContext.h"
#import "MSAIEnvelope.h"
#import "MSAIHTTPOperation.h"
#import "MSAIAppClient.h"

@implementation MSAIChannel{
  MSAIClientContext *_clientContext;
  MSAIAppClient *_appClient;
}

- (instancetype)initWithAppClient:(MSAIAppClient *) appClient clientContext:(MSAIClientContext *)clientContext{
  
  if ((self = [self init])) {
    _clientContext = clientContext;
    _appClient = appClient;
  }
  return self;
}

- (void)sendDataItem:(MSAITelemetryData *)dataItem{
  
  MSAIEnvelope *envelope = [MSAIEnvelope new];
  NSURLRequest *request = [self requestForDataItem:envelope];
  [self enqueueRequest:request];
  
}

- (NSURLRequest *)requestForDataItem:(MSAIEnvelope *)dataItem {
  
  NSMutableURLRequest *request = [_appClient requestWithMethod:@"POST"
                                                          path:[_clientContext endpointPath]
                                                    parameters:nil];
  
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
                                      }
                                    }else{
                                      NSLog(@"Sending failed");
                                    }
                                  }];
  
  [_appClient enqeueHTTPOperation:operation];
}

@end
