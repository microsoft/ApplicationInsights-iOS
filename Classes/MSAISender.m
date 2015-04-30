#import "MSAISender.h"
#import "MSAIAppClient.h"
#import "MSAISenderPrivate.h"
#import "MSAIPersistence.h"
#import "MSAIGZIP.h"
#import "MSAIEnvelope.h"
#import "ApplicationInsights.h"
#import "ApplicationInsightsPrivate.h"
#import "MSAIApplicationInsights.h"

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

- (void)configureWithAppClient:(MSAIAppClient *)appClient {
  self.appClient = appClient;
  self.maxRequestCount = defaultRequestLimit;
  [self registerObservers];
}

#pragma mark - Handle persistence events

- (void)registerObservers{
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  __weak typeof(self) weakSelf = self;
  [center addObserverForName:MSAIPersistenceSuccessNotification
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
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    typeof(self) strongSelf = weakSelf;
    NSString *path = [[MSAIPersistence sharedInstance] requestNextPath];
    NSData *data = [[MSAIPersistence sharedInstance] dataAtPath:path];
    NSData *gzippedData = [data gzippedData];
    [strongSelf sendData:gzippedData withPath:path];
  });
}

- (void)sendData:(NSData *)data withPath:(NSString *)path{
  
  if(data) {
    NSURLRequest *request = [self requestForData:data];
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
      MSAILog(@"Sending MSAIApplicationInsights data failed");
      MSAILog(@"Error description: %@", error.localizedDescription);
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

- (NSURLRequest *)requestForData:(NSData *)data {
  NSMutableURLRequest *request = [self.appClient requestWithMethod:@"POST"
                                                              path:self.endpointPath
                                                        parameters:nil];
  
  request.HTTPBody = data;
  request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
  
  NSDictionary *headers = @{@"Charset": @"UTF-8",
                            @"Content-Encoding": @"gzip",
                            @"Content-Type": @"application/json",
                            @"Accept-Encoding": @"gzip"};
  [request setAllHTTPHeaderFields:headers];
  
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
