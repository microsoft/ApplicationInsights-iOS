#import "MSAISender.h"
#import "MSAIAppClient.h"
#import "MSAISenderPrivate.h"
#import "MSAIPersistence.h"
#import "MSAIEnvelope.h"
#import "AppInsights.h"
#import "AppInsightsPrivate.h"
#import "MSAIAppInsights.h"

@interface MSAISender ()

@end

static NSUInteger const defaultRequestLimit = 10;

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
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                      
                      [strongSelf sendSavedData];
                    });
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
  NSString *path = [[MSAIPersistence sharedInstance] requestNextPath];
  NSArray *bundle = [[MSAIPersistence sharedInstance] bundleAtPath:path];
  [self sendBundle:bundle withPath:path];
}

- (void)sendBundle:(NSArray *)bundle withPath:(NSString *)path{
  
  if(bundle && bundle.count > 0) {
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:[self jsonArrayFromArray:bundle] options:NSJSONWritingPrettyPrinted error:&error];
    if(!error) {
      NSString *urlString = [[(MSAIEnvelope *)bundle[0] name] isEqualToString:@"Microsoft.ApplicationInsights.Crash"] ? MSAI_CRASH_DATA_URL : MSAI_EVENT_DATA_URL;
      NSURLRequest *request = [self requestForData:json urlString:urlString];
      [self sendRequest:request path:path];
    }else {
      MSAILog(@"Error creating JSON from bundle array, don't save back to disk");
      self.runningRequestsCount -= 1;
    }
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

    if(statusCode >= 200 && statusCode <= 400) {
      
      // We should delete data if it has been succesfully sent (200/202) or if its values have not been accepted (400)
      MSAILog(@"Sent data with status code: %ld", (long) statusCode);
      MSAILog(@"Response data:\n%@", [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil]);
      
      [[MSAIPersistence sharedInstance] deleteBundleAtPath:path];
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
