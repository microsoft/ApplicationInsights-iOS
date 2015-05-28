#import "MSAISender.h"
#import "MSAIAppClient.h"
#import "MSAISenderPrivate.h"
#import "MSAIPersistence.h"
#import "MSAIGZIP.h"
#import "MSAIEnvelope.h"
#import "ApplicationInsights.h"
#import "ApplicationInsightsPrivate.h"
#import "MSAIApplicationInsights.h"

static char const *kPersistenceQueueString = "com.microsoft.ApplicationInsights.senderQueue";
static NSUInteger const defaultRequestLimit = 10;

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

- (instancetype)init {
  if ((self = [super init])) {
    _senderQueue = dispatch_queue_create(kPersistenceQueueString, DISPATCH_QUEUE_CONCURRENT);
  }
  return self;
}

#pragma mark - Network status

- (void)configureWithAppClient:(MSAIAppClient * __nonnull)appClient {
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
    
    [strongSelf sendData:[data gzippedData] withPath:path];
  });
}

- (void)sendData:(NSData * __nonnull)data withPath:(NSString * __nonnull)path {
  
  if(data) {
    NSURLRequest *request = [self requestForData:data];
    [self sendRequest:request path:path];
    
  } else {
    self.runningRequestsCount -= 1;
  }
}

- (void)sendRequest:(NSURLRequest * __nonnull)request path:(NSString * __nonnull)path {
  
  if(!path || !request) return;
  
  __weak typeof(self) weakSelf = self;
  MSAIHTTPOperation *operation = [self.appClient operationWithURLRequest:request queue:self.senderQueue completion:^(MSAIHTTPOperation *operation, NSData *responseData, NSError *error) {
    typeof(self) strongSelf = weakSelf;

    self.runningRequestsCount -= 1;
    NSInteger statusCode = [operation.response statusCode];

    if(responseData && [self shouldDeleteDataWithStatusCode:statusCode]) {
      //we delete data that was either sent successfully or if we have a non-recoverable error
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

#pragma mark - Helper

- (NSURLRequest *)requestForData:(NSData * __nonnull)data {
  NSMutableURLRequest *request = [self.appClient requestWithMethod:@"POST"
                                                              path:self.endpointPath
                                                        parameters:nil];
  
  request.HTTPBody = data;
  request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
  
  NSDictionary *headers = @{@"Charset": @"UTF-8",
                            @"Content-Encoding": @"gzip",
                            @"Content-Type": @"application/x-json-stream",
                            @"Accept-Encoding": @"gzip"};
  [request setAllHTTPHeaderFields:headers];
  
  return request;
}

//some status codes represent recoverable error codes
//we try sending again some point later
- (BOOL)shouldDeleteDataWithStatusCode:(NSInteger)statusCode {
  NSArray *recoverableStatusCodes = @[@429, @408, @500, @503, @511];

  return ![recoverableStatusCodes containsObject:@(statusCode)];
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
