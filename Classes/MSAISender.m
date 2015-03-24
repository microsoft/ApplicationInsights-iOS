#import "MSAISender.h"
#import "MSAIAppClient.h"
#import "MSAISenderPrivate.h"
#import "MSAIPersistence.h"
#import "MSAIEnvelope.h"
#import "AppInsights.h"
#import "AppInsightsPrivate.h"
#import "MSAIAppInsights.h"

static NSUInteger const defaultRequestLimit = 10;

static NSInteger const statusCodeOK = 200;
static NSInteger const statusCodeAccepted = 202;
static NSInteger const statusCodeBadRequest = 400;

@interface MSAISender ()

@end

@implementation MSAISender

@synthesize runningRequestsCount = _runningRequestsCount;

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
  self.maxRequestCount = defaultRequestLimit;
  [self registerObservers];
}

#pragma mark - Handle persistence events

- (void)registerObservers{
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  __weak typeof(self) weakSelf = self;
  [center addObserverForName:kMSAIPersistenceSuccessNotification
                      object:nil
                       queue:nil
                  usingBlock:^(NSNotification *notification) {
                    typeof(self) strongSelf = weakSelf;
                    
                    [strongSelf sendSavedData];
                    
                  }];
}

#pragma mark - Sending

- (void)sendSavedData{
  
  @synchronized(self){
    if(_runningRequestsCount < _maxRequestCount){
      _runningRequestsCount++;
    }else{
      return;
    }
  }
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSString *path = [[MSAIPersistence sharedInstance] requestNextPath];
    NSData *data = [[MSAIPersistence sharedInstance] dataAtPath:path];
    [self sendData:data withPath:path];
  });
}

- (void)sendData:(NSData *)data withPath:(NSString *)path{
  
  if(data) {
    NSString *urlString = MSAI_EVENT_DATA_URL;
    NSURLRequest *request = [self requestForData:data urlString:urlString];
    [self sendRequest:request path:path];
    
  }else{
    self.runningRequestsCount -= 1;
  }
}

- (void)sendRequest:(NSURLRequest *)request path:(NSString *)path{
  
  if(!path || !request) return;
  
  __weak typeof(self) weakSelf = self;
  MSAIHTTPOperation *operation = [self.appClient operationWithURLRequest:request completion:^(MSAIHTTPOperation *operation, NSData *responseData, NSError *error) {
    typeof(self) strongSelf = weakSelf;
    
    self.runningRequestsCount -= 1;
    NSInteger statusCode = [operation.response statusCode];

    if([self shouldDeleteDataWithStatusCode:statusCode]) {
      // We should delete data if it has been succesfully sent (200/202) or if its values have not been accepted (400)
      MSAILog(@"Sent data with status code: %ld", (long) statusCode);
      MSAILog(@"Response data:\n%@", [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil]);
      
      [[MSAIPersistence sharedInstance] deleteFileAtPath:path];
      [strongSelf sendSavedData];
    } else {
      MSAILog(@"Sending MSAIAppInsights data failed");
      [[MSAIPersistence sharedInstance] giveBackRequestedPath:path];
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

- (BOOL)shouldDeleteDataWithStatusCode:(NSInteger)statusCode {
  
  return (statusCode >= statusCodeOK && statusCode <= statusCodeAccepted) || statusCode == statusCodeBadRequest;
}

#pragma mark - Getter/Setter

- (NSUInteger)runningRequestsCount {
  @synchronized(self) {
    return _runningRequestsCount;
  }
}

- (void)setRunningRequestsCount:(NSUInteger)runningRequestsCount {
  @synchronized(self) {
    _runningRequestsCount = runningRequestsCount;
  }
}

@end
