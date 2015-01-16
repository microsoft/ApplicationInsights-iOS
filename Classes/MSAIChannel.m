#import "MSAIChannel.h"
#import "MSAITelemetryContext.h"
#import "MSAIEnvelope.h"
#import "MSAIHTTPOperation.h"
#import "MSAIAppClient.h"
#import "AppInsightsPrivate.h"
#import "MSAIData.h"

@implementation MSAIChannel{
  MSAITelemetryContext *_telemetryContext;
  MSAIAppClient *_appClient;
}

- (instancetype)initWithAppClient:(MSAIAppClient *) appClient telemetryContext:(MSAITelemetryContext *)telemetryContext {
  
  if ((self = [self init])) {
    _telemetryContext = telemetryContext;
    _appClient = appClient;
  }
  return self;
}

- (void)sendDataItem:(MSAITelemetryData *)dataItem{
  
  [dataItem setVersion:@(2)];
  
  MSAIData *data = [MSAIData new];
  [data setBaseData:dataItem];
  [data setBaseType:[dataItem dataTypeName]];
  
  MSAIEnvelope *envelope = [MSAIEnvelope new];
  [envelope setTime:self.dateString];
  [envelope setIKey:[_telemetryContext instrumentationKey]];
  [envelope setData:data];
  [envelope setName:[dataItem envelopeTypeName]];
  [envelope setTags:[_telemetryContext contextDictionary]];
  
  NSURLRequest *request = [self requestForDataItem:envelope];
  [self enqueueRequest:request];
}

- (NSURLRequest *)requestForDataItem:(MSAIEnvelope *)dataItem {
  
  NSMutableURLRequest *request = [_appClient requestWithMethod:@"POST"
                                                          path:[_telemetryContext endpointPath]
                                                    parameters:nil];
  
  NSString *dataString = [dataItem serializeToString];
  NSData *requestData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
  [request setHTTPBody:requestData];
  
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

- (NSString *)dateString{
  NSDateFormatter *dateFormatter = [NSDateFormatter new];
  dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
  NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
  return dateString;
}

@end
