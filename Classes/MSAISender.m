#import "MSAISender.h"
#import "MSAIAppClient.h"
#import "MSAISenderPrivate.h"
#import "MSAIPersistence.h"
#import "MSAIEnvelope.h"

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
      NSURLRequest *request = [self requestForData:json];
      [self sendRequest:request];
    }
    else {
      NSLog(@"Error creating JSON from bundle array, saving bundle back to disk");
      [MSAIPersistence persistBundle:bundle ofType:MSAIPersistenceTypeRegular withCompletionBlock:nil];
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
                                    self.currentBundle = nil;
                                    self.sending = NO;
                                    if(statusCode >= 200 && statusCode < 400) {
                                      
                                      NSLog(@"Sent data with status code: %ld", (long) statusCode);
                                      NSLog(@"Response data:\n%@", [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil]);
                                      
                                      [strongSelf sendSavedData];
                                      
                                    } else {
                                      NSLog(@"Sending failed");
                                    
                                      //[MSAIPersistence persistBundle:self.currentBundle];
                                      //TODO trigger sending again -> later and somewhere else?!
                                    }
                                  }];
  
  [self.appClient enqeueHTTPOperation:operation];
}

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

- (NSURLRequest *)requestForData:(NSData *)data {
  NSMutableURLRequest *request = [self.appClient requestWithMethod:@"POST"
                                                              path:self.endpointPath
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
