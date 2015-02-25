#import "MSAISender.h"
#import "MSAIAppClient.h"
#import "MSAISenderPrivate.h"
#import "MSAIPersistence.h"
#import "MSAIEnvelope.h"
#import "AppInsights.h"
#import "AppInsightsPrivate.h"
#import "MSAIAppInsights.h"

@interface MSAISender ()

@property (nonatomic, strong) NSArray *currentBundle;
@property (getter=isSending) BOOL sending;

@end

@implementation MSAISender

@synthesize sending = _sending;

#pragma mark - Initialize & configure shared instance

+ (instancetype)sharedSender {
  static MSAISender *sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [MSAISender new];
  });
  return sharedInstance;
}

#pragma mark - Network status

- (void)configureWithAppClient:(MSAIAppClient *)appClient endpointPath:(NSString *)endpointPath {
  self.endpointPath = endpointPath;
  self.appClient = appClient;
  [self registerObservers];
}

#pragma mark - Handle persistence events

- (void)registerObservers{
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  __weak typeof(self) weakSelf = self;
  [center addObserverForName:kMSAIPersistenceSuccessNotification
                      object:nil
                       queue:nil
                  usingBlock:^(NSNotification *note) {
                    typeof(self) strongSelf = weakSelf;
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                      
                      // If something was persisted, we have to send it to the server.
                      [strongSelf sendSavedData];
                    });
                  }];
}

#pragma mark - Sending

- (void)sendSavedData {
  
  @synchronized(self){
    if(_sending)
      return;
    else
      _sending = YES;
  }
  
  NSArray *bundle = [MSAIPersistence nextBundle];
  if(bundle && bundle.count > 0 && !self.currentBundle) {
    self.currentBundle = bundle;
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:[self jsonArrayFromArray:bundle] options:NSJSONWritingPrettyPrinted error:&error];
    if(!error) {
      NSString *urlString = [[(MSAIEnvelope *)bundle[0] name] isEqualToString:@"Microsoft.ApplicationInsights.Crash"] ? MSAI_CRASH_DATA_URL : MSAI_EVENT_DATA_URL;
      NSURLRequest *request = [self requestForData:json urlString:urlString];
      [self sendRequest:request];
    }
    else {
      MSAILog(@"Error creating JSON from bundle array, don't save back to disk");
      self.sending = NO;
    }
  }else{
    self.sending = NO;
  }
}

- (void)sendRequest:(NSURLRequest *)request {
  __weak typeof(self) weakSelf = self;
  
  MSAIHTTPOperation *operation = [self.appClient
                                  operationWithURLRequest:request
                                  completion:^(MSAIHTTPOperation *operation, NSData *responseData, NSError *error) {
                                    
                                    typeof(self) strongSelf = weakSelf;
                                    NSInteger statusCode = [operation.response statusCode];

                                    if(statusCode >= 200 && statusCode < 400) {
                                      MSAILog(@"Sent data with status code: %ld", (long) statusCode);
                                      MSAILog(@"Response data:\n%@", [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil]);
                                      strongSelf.currentBundle = nil;
                                      strongSelf.sending = NO;
                                      [strongSelf sendSavedData];
                                    } else {
                                      MSAILog(@"Sending MSAIAppInsights data failed");
                                      MSAILog(@"Response data:\n%@", [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil]);
                                      [MSAIPersistence persistAfterErrorWithBundle:weakSelf.currentBundle];
                                      strongSelf.currentBundle = nil;
                                      strongSelf.sending = NO;
                                    }
                                  }];
  
  [self.appClient enqeueHTTPOperation:operation];
}

//TODO remove this because it is never used and it's not public?
- (void)sendRequest:(NSURLRequest *)request withCompletionBlock:(MSAINetworkCompletionBlock)completion{
  MSAIHTTPOperation *operation = [_appClient
                                  operationWithURLRequest:request
                                  completion:completion];
  [_appClient enqeueHTTPOperation:operation];
}

#pragma mark - Helper

- (NSArray *)jsonArrayFromArray:(NSArray *)envelopeArray{
  NSMutableArray *array = [NSMutableArray new];
  for(MSAIEnvelope *envelope in envelopeArray){
    [array addObject:[envelope serializeToDictionary]];
  }
  return array;
}

- (NSURLRequest *)requestForData:(NSData *)data urlString:(NSString *)urlString {
  NSMutableURLRequest *request = [self.appClient requestWithMethod:@"POST"
                                                              path:urlString
                                                        parameters:nil];
  
  [request setHTTPBody:data];
  [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
  NSString *contentType = @"application/json";
  [request setValue:contentType forHTTPHeaderField:@"Content-type"];
  return request;
}

#pragma mark - Getter/Setter

- (BOOL)isSending {
  @synchronized(self){
    return _sending;
  }
}

- (void)setSending:(BOOL)sending {
  @synchronized(self){
    _sending = sending;
  }
}

@end
