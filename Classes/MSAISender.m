#import "MSAISender.h"
#import "MSAIAppClient.h"
#import "MSAISenderPrivate.h"
#import "MSAIPersistence.h"
#import "MSAIPersistencePrivate.h"
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
  [self configureWithAppClient:appClient endpointPath:endpointPath delegate:nil];
}

- (void)configureWithAppClient:(MSAIAppClient *)appClient endpointPath:(NSString *)endpointPath delegate:(id)delegate {
  self.endpointPath = endpointPath;
  self.appClient = appClient;
  self.maxRequestCount = defaultRequestLimit;
  self.delegate = delegate;
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
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSString *path = [[MSAIPersistence sharedInstance] requestNextPath];
    NSData *data = [[MSAIPersistence sharedInstance] dataAtPath:path];
    [self sendData:data withPath:path];
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
  
  // Inform delegate
  NSArray *bundle;
  MSAIPersistenceType type = [[MSAIPersistence sharedInstance] persistenceTypeForPath:path];
  if(self.delegate && type == MSAIPersistenceTypeHighPriority && [self.delegate respondsToSelector:@selector(appInsightsWillSendCrashDict:)]){
    bundle = [[MSAIPersistence sharedInstance] bundleAtPath:path withPersistenceType:type];
    NSDictionary *crashDict = bundle.count > 0 ? bundle[0] : nil;
    [self.delegate appInsightsWillSendCrashDict:crashDict];
  }
  
  __weak typeof(self) weakSelf = self;
  MSAIHTTPOperation *operation = [self.appClient operationWithURLRequest:request completion:^(MSAIHTTPOperation *operation, NSData *responseData, NSError *error) {
    typeof(self) strongSelf = weakSelf;
    
    strongSelf.runningRequestsCount -= 1;
    NSInteger statusCode = [operation.response statusCode];
    
    // Delete file if it has been succesfully sent (200/202) or if its values have not been accepted (400)
    if([self shouldDeleteDataWithStatusCode:statusCode]) {
      MSAILog(@"Sent data with status code: %ld", (long) statusCode);
      MSAILog(@"Response data:\n%@", [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil]);
      [[MSAIPersistence sharedInstance] deleteFileAtPath:path];
      [strongSelf sendSavedData];
    } else {
      MSAILog(@"Sending MSAIAppInsights data failed");
      MSAILog(@"Error description: %@", error.localizedDescription);
      [[MSAIPersistence sharedInstance] giveBackRequestedPath:path];
    }
    
    // Inform delegate
    if(statusCode >= 200 && statusCode <= 202){
      if(strongSelf.delegate && type == MSAIPersistenceTypeHighPriority && [strongSelf.delegate respondsToSelector:@selector(appInsightsDidFinishSendingCrashDict:)]){
        NSDictionary *crashDict = bundle.count > 0 ? bundle[0] : nil;
        [strongSelf.delegate appInsightsDidFinishSendingCrashDict:crashDict];
      }
    }else{
      if(strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(appInsightsDidFailWithError:)]){
        [strongSelf.delegate appInsightsDidFailWithError:error];
      }
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
