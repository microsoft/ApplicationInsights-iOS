#import "MSAISender.h"
#import "MSAIAppClient.h"
#import "MSAISenderPrivate.h"
#import "MSAIPersistence.h"


@interface MSAISender ()

@property (nonatomic, strong) NSArray *currentBundle;

@end

@implementation MSAISender

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

- (void)registerObservers{
  
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  __weak typeof(self) weakSelf = self;
  [center addObserverForName:kMSAIPersistenceSuccessNotification
                      object:nil
                       queue:nil
                  usingBlock:^(NSNotification *note) {
                    typeof(self) strongSelf = weakSelf;
                    [strongSelf sendSavedData];
                    NSLog(@"Successfully persisted");
  }];
  
  
}

#pragma mark - Sending

- (void)sendSavedData {
  NSArray *bundle = [MSAIPersistence nextBundle];
  if(bundle && !self.currentBundle) {
    self.currentBundle = bundle;
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:bundle options:NSJSONWritingPrettyPrinted error:&error];
    if(!error) {
      NSURLRequest *request = [self requestForData:json];
      [self sendRequest:request];
    }
    else {
      NSLog(@"Error creating JSON from bundle array, saving bundle back to disk");
      [MSAIPersistence persistBundle:bundle withPriority:MSAIPersistencePriorityRegular withCompletionBlock:nil];
        //TODO: more error handling!
    }
  }
  
}

- (void)sendRequest:(NSURLRequest *)request {
  __weak typeof(self) weakSelf = self;
  
  MSAIHTTPOperation *operation = [self.appClient
                                  operationWithURLRequest:request
                                  completion:^(MSAIHTTPOperation *operation, NSData *responseData, NSError *error) {
                                    
                                    typeof(self) strongSelf = weakSelf;
                                    NSInteger statusCode = [operation.response statusCode];
                                    
                                    if(nil == error) {
                                      if(nil == responseData || [responseData length] == 0) {
                                        NSLog(@"Sending failed with an empty response!");
                                      } else {
                                        NSLog(@"Sent data with status code: %ld", (long) statusCode);
                                        NSLog(@"Response data:\n%@", [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil]);
                                        self.currentBundle = nil;
                                        [strongSelf sendSavedData];
                                      }
                                    } else {
                                      NSLog(@"Sending failed");
                                      //[MSAIPersistence persistBundle:self.currentBundle];
                                      self.currentBundle = nil;
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

@end
