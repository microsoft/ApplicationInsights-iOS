#import "MSAISender.h"
#import "MSAIHelper.h"
#import "MSAIAppClient.h"
#import "MSAISenderPrivate.h"
#import "MSAIPersistencePrivate.h"
#import "MSAIGZIP.h"
#import "ApplicationInsightsPrivate.h"

static char const *kPersistenceQueueString = "com.microsoft.ApplicationInsights.senderQueue";
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
    if (data && path) {
      [strongSelf sendData:data withPath:path];
    }
  });
}

- (void)sendData:(NSData * __nonnull)data withPath:(NSString * __nonnull)path {
  if(data && data.length > 0) {
    NSString *contentType = [self contentTypeForData:data];

    NSData *gzippedData = [data gzippedData];
    NSURLRequest *request = [self requestForData:gzippedData withContentType:contentType];
    
    id nsurlsessionClass = NSClassFromString(@"NSURLSessionUploadTask");
    if (nsurlsessionClass && !msai_isRunningInAppExtension()) {
      [self startUploadTaskWithRequest:request data:gzippedData path:path];
    } else {
      [self sendRequest:request path:path];
    }
  } else {
    self.runningRequestsCount -= 1;
  }
}

- (void)startUploadTaskWithRequest:(nonnull NSURLRequest *)request data:(nonnull NSData *)data path:(nonnull NSString *)path {
  
  if (!request || !data || !path) { return; }
  
  NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];

  __weak typeof (self) weakSelf = self;
  // The body data of our request are ignored so it is passed separately
  NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                             fromData:data
                                                    completionHandler:^(NSData *responseData, NSURLResponse *response, NSError *error) {
                                                      typeof (self) strongSelf = weakSelf;
                                                      
                                                      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                      NSInteger statusCode = httpResponse.statusCode;
                                                      [strongSelf handleUploadResultWithPath:path responseData:responseData error:error statusCode:statusCode];
                                                    }];
  
  [uploadTask resume];
}

- (void)sendRequest:(nonnull NSURLRequest *)request path:(nonnull NSString *)path {
  
  if(!path || !request) { return; }
  
  __weak typeof(self) weakSelf = self;
  MSAIHTTPOperation *operation = [self.appClient operationWithURLRequest:request queue:self.senderQueue completion:^(MSAIHTTPOperation *completedOperation, NSData *responseData, NSError *error) {
    typeof(self) strongSelf = weakSelf;

    NSInteger statusCode = [completedOperation.response statusCode];
    [strongSelf handleUploadResultWithPath:path responseData:responseData error:error statusCode:statusCode];
  }];

  [self.appClient enqueueHTTPOperation:operation];
}

- (void)handleUploadResultWithPath:(nonnull NSString *)path responseData:(nonnull NSData *)responseData error:(nonnull NSError *)error statusCode:(NSInteger)statusCode {
  self.runningRequestsCount -= 1;

  if(responseData && [self shouldDeleteDataWithStatusCode:statusCode]) {
      //we delete data that was either sent successfully or if we have a non-recoverable error
      MSAILog(@"Sent data with status code: %ld", (long) statusCode);
      MSAILog(@"Response data:\n%@", [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil]);
      [[MSAIPersistence sharedInstance] deleteFileAtPath:path];
      [self sendSavedData];
    } else {
      MSAILog(@"Sending MSAIApplicationInsights data failed");
      MSAILog(@"Error description: %@", error.localizedDescription);
      [[MSAIPersistence sharedInstance] giveBackRequestedPath:path];
    }
}

#pragma mark - Helper

- (NSURLRequest *)requestForData:(NSData * __nonnull)data withContentType:(NSString * __nonnull)contentType {
  NSMutableURLRequest *request = [self.appClient requestWithMethod:@"POST"
                                                              path:self.endpointPath
                                                        parameters:nil];
  
  request.HTTPBody = data;
  request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
  
  NSDictionary *headers = @{@"Charset": @"UTF-8",
                            @"Content-Encoding": @"gzip",
                            @"Content-Type": contentType,
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

- (NSString *)contentTypeForData:(NSData *)data {
  NSString *contentType;
  static const uint8_t LINEBREAK_SIGNATURE = (0x0a);
  UInt8 lastByte = 0;
  if (data && data.length > 0) {
    [data getBytes:&lastByte range:NSMakeRange(data.length-1, 1)];
  }
  
  if (data && (data.length > sizeof(uint8_t)) && (lastByte == LINEBREAK_SIGNATURE)) {
    contentType = @"application/x-json-stream";
  } else {
    contentType = @"application/json";
  }
  return contentType;
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
