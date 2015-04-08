#import "MSAIHTTPOperation.h"

@interface MSAIHTTPOperation ()<NSURLConnectionDelegate>

@property(nonatomic, strong) NSURLConnection *connection;
@property(nonatomic) BOOL isExecuting;
@property(nonatomic) BOOL isFinished;

@end

@implementation MSAIHTTPOperation {
  NSMutableData *_data;
}

+ (instancetype)operationWithRequest:(NSURLRequest *)urlRequest {
  MSAIHTTPOperation *op = [[self class] new];
  op->_URLRequest = urlRequest;
  return op;
}

#pragma mark - NSOperation overrides
- (BOOL)isConcurrent {
  return YES;
}

- (void)cancel {
  [self.connection cancel];
  [super cancel];
}

- (void) start {
  if(self.isCancelled) {
    [self finish];
    return;
  }
  
  if (![[NSThread currentThread] isMainThread]) {
    [self performSelector:@selector(start) onThread:NSThread.mainThread withObject:nil waitUntilDone:NO];
    return;
  }
  
  if(self.isCancelled) {
    [self finish];
    return;
  }

  [self willChangeValueForKey:@"isExecuting"];
  self.isExecuting = YES;
  [self didChangeValueForKey:@"isExecuting"];
  
  self.connection = [[NSURLConnection alloc] initWithRequest:self.URLRequest
                                                delegate:self
                                        startImmediately:YES];
}

- (void) finish {
  [self willChangeValueForKey:@"isExecuting"];
  [self willChangeValueForKey:@"isFinished"];
  self.isExecuting = NO;
  self.isFinished = YES;
  [self didChangeValueForKey:@"isExecuting"];
  [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - NSURLConnectionDelegate

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
  _data = [[NSMutableData alloc] init];
  _response = (id)response;
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
  [_data appendData:data];
}

-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
  //FINISHED and failed
  _error = error;
  _data = nil;
  
  [self finish];
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection {
  [self finish];
}

#pragma mark - Public interface
- (NSData *)data {
  return _data;
}

- (void)setCompletion:(MSAINetworkCompletionBlock)completion {
  if(!completion) {
    [super setCompletionBlock:nil];
  } else {
    __weak typeof(self) weakSelf = self;
    [super setCompletionBlock:^{
      typeof(self) strongSelf = weakSelf;
      if(strongSelf) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if(!strongSelf.isCancelled) {
            completion(strongSelf, strongSelf.data, strongSelf.error);
          }
          [strongSelf setCompletionBlock:nil];
        });
      }
    }];
  }
}

@end
