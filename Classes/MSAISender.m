#import "MSAISender.h"
#import "MSAIAppClient.h"
#import "MSAISenderPrivate.h"

#ifdef DEBUG
static NSInteger const defaultMaxBatchCount = 150; //TODO are these values defined?!
static NSInteger const defaultBatchInterval = 15;
#else
static NSInteger const defaultMaxBatchCount = 5;
static NSInteger const defaultBatchInterval = 15;
#endif

static char *const MSAIDataItemsOperationsQueue = "com.microsoft.appInsights.senderQueue";

@interface MSAISender()

@property (nonatomic, copy) NSString *currentFilePath;

@end


@implementation MSAISender

//TODO: split sending and persisting in two

#pragma mark - Initialize & configure shared instance

+ (instancetype)sharedSender {
  static MSAISender *sharedInstance = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    sharedInstance = [MSAISender new];
    dispatch_queue_t serialQueue = dispatch_queue_create(MSAIDataItemsOperationsQueue, DISPATCH_QUEUE_SERIAL);
    [sharedInstance setDataItemsOperations:serialQueue];

  });
  return sharedInstance;
}

- (instancetype)init {
  if(self = [super init]) {
    self.dataItemQueue = [NSMutableArray array];
    self.senderThreshold = defaultMaxBatchCount;
    self.senderInterval = defaultBatchInterval;
  }
  return self;
}

- (void)configureWithAppClient:(MSAIAppClient *)appClient endpointPath:(NSString *)endpointPath {
  self.endpointPath = endpointPath;
  self.appClient = appClient;
}

#pragma mark - Queue management

- (NSMutableArray *)dataItemQueue {

  __block NSMutableArray *queue = nil;
  __weak typeof(self) weakSelf = self;
  dispatch_sync(self.dataItemsOperations, ^{
    typeof(self) strongSelf = weakSelf;

    queue = [NSMutableArray arrayWithArray:strongSelf->_dataItemQueue];
  });
  return queue;
}

- (void)enqueueDataDict:(NSDictionary *)dataDict {
  if(dataDict) {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.dataItemsOperations, ^{
      typeof(self) strongSelf = weakSelf;

      [strongSelf->_dataItemQueue addObject:dataDict];

      if([strongSelf->_dataItemQueue count] >= strongSelf.senderThreshold) {
        [strongSelf invalidateTimer];
        [strongSelf persistQueue];
      } else if([strongSelf->_dataItemQueue count] == 1) {
        [strongSelf startTimer];
      }
    });
  }
}

#pragma mark - Timer

- (void)invalidateTimer {
  if(self.timerSource) {
    dispatch_source_cancel(self.timerSource);
    self.timerSource = nil;
  }
}

- (void)startTimer {

  if(self.timerSource) {
    [self invalidateTimer];
  }

  self.timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.dataItemsOperations);
  dispatch_source_set_timer(self.timerSource, dispatch_walltime(NULL, NSEC_PER_SEC * self.senderInterval), 1ull * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
  dispatch_source_set_event_handler(self.timerSource, ^{
    [self invalidateTimer];
    [self persistQueue];
  });
  dispatch_resume(self.timerSource);
}

#pragma mark - Persistence

- (void)persistQueue {
  //NSError *error = nil;
  //NSData *json = [NSJSONSerialization dataWithJSONObject:self.dataItemQueue options:NSJSONWritingPrettyPrinted error:&error];
  //NSURLRequest *request = [self requestForData:json];
  //[self sendRequest:request];

  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[self.dataItemQueue copy]]; //use immutable copy
  __weak typeof(self) weakSelf = self;

  //TODO check if we need the queue at all!
  dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(backgroundQueue, ^{
    typeof(self) strongSelf = weakSelf;
    NSString *fileURL = [strongSelf fileURL];
    if([data writeToFile:fileURL atomically:YES]) {
      NSLog(@"Wrote %@", fileURL);
    }
    else {
      NSLog(@"Unable to write %@", fileURL);
    }

  });

  [self.dataItemQueue removeAllObjects];

  [self triggerSending];
}

- (NSString *)fileURL {
  NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  NSString *timestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
  NSString *fileName = [NSString stringWithFormat:@"app-insights-bundle-%@", timestamp];
  NSString *filePath = [cachesFolder stringByAppendingPathComponent:fileName];

  return filePath;
}

- (NSArray *)persistedFilePaths {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSArray *filePaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory  error:nil];
  NSLog(@"All saved bundles %@", filePaths);

  return filePaths;
}

- (void)deleteCurrentBundle {
  if((self.currentFilePath) && ([self.currentFilePath isKindOfClass:[NSString class]]) && (self.currentFilePath.length > 0)) {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.currentFilePath error:&error];
    if(error) {
      NSLog(@"Error deleting file at path %@", self.currentFilePath);
    }
    else {
      NSLog(@"Successfully deleted file at path %@", self.currentFilePath);
    }
    self.currentFilePath = nil;
    //TODO check if we might get a problem here!
  }
}



#pragma mark - Sending

- (void)triggerSending {
  if(([[self persistedFilePaths] count] > 0) && (!self.currentFilePath)) {
    self.currentFilePath = [[self persistedFilePaths] firstObject];
    NSArray *bundle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.currentFilePath];
    NSError *error = nil;

    NSData *json = [NSJSONSerialization dataWithJSONObject:bundle options:NSJSONWritingPrettyPrinted error:&error];
    if(!error) {
      NSURLRequest *request = [self requestForData:json];
      [self sendRequest:request];
    }
    else {
      NSLog(@"Error creating JSON from bundle array");
      //TODO: more error handling!
    }
  }
  else {
    if([self currentFilePath]) {
      NSLog(@"Already sending another file");
    }
    else {
      NSLog(@"Nothing to send");
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
                         [strongSelf deleteCurrentBundle];
                         [strongSelf triggerSending];
                       }
                     } else {
                       NSLog(@"Sending failed");
                       strongSelf.currentFilePath = nil;
                       //TODO trigger sending again -> later and somewhere else?!
                     }
                   }];

  [self.appClient enqeueHTTPOperation:operation];
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
