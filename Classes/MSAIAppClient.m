#import "MSAIAppClient.h"

@implementation MSAIAppClient
- (void)dealloc {
  [self cancelAllOperations];
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL {
  self = [super init];
  if ( self ) {
    NSParameterAssert(baseURL);
    _baseURL = baseURL;
  }
  return self;
}

#pragma mark - Networking
- (NSMutableURLRequest *)requestWithMethod:(NSString*)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)params {
  
  path = path ? : @"";
  
  NSURL *endpoint = [self.baseURL URLByAppendingPathComponent:path];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:endpoint];
  request.HTTPMethod = method;
  
  if (params) {
    if ([method isEqualToString:@"GET"]) {
      NSString *absoluteURLString = [endpoint absoluteString];
      //either path already has parameters, or not
      NSString *appenderFormat = [path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@";
      
      endpoint = [NSURL URLWithString:[absoluteURLString stringByAppendingFormat:appenderFormat,
                                       [self.class queryStringFromParameters:params withEncoding:NSUTF8StringEncoding]]];
      [request setURL:endpoint];
    } else {
      //TODO: Boundary should be the same as the one in appendData
      //unify this!
      NSString *boundary = @"----FOO";
      NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
      [request setValue:contentType forHTTPHeaderField:@"Content-type"];
      
      NSMutableData *postBody = [NSMutableData data];
      [params enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [postBody appendData:[[self class] dataWithPostValue:value forKey:key boundary:boundary]];
      }];
      
      [postBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
      
      [request setHTTPBody:postBody];
    }
  }
  
  return request;
}

+ (NSData *)dataWithPostValue:(NSString *)value forKey:(NSString *)key boundary:(NSString *) boundary {
  return [self dataWithPostValue:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:key contentType:@"text" boundary:boundary filename:nil];
}

+ (NSData *)dataWithPostValue:(NSData *)value forKey:(NSString *)key contentType:(NSString *)contentType boundary:(NSString *) boundary filename:(NSString *)filename {
  NSMutableData *postBody = [NSMutableData data];
  
  [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  
  // There's certainly a better way to check if we are supposed to send binary data here. 
  if (filename){
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", contentType] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
  } else {
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", contentType] dataUsingEncoding:NSUTF8StringEncoding]];
  }
  
  [postBody appendData:value];
  [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  
  return postBody;
}


+ (NSString *) queryStringFromParameters:(NSDictionary *) params withEncoding:(NSStringEncoding) encoding {
  NSMutableString *queryString = [NSMutableString new];
  [params enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL *stop) {
    NSAssert([key isKindOfClass:[NSString class]], @"Query parameters can only be string-string pairs");
    NSAssert([value isKindOfClass:[NSString class]], @"Query parameters can only be string-string pairs");
    
    [queryString appendFormat:queryString.length ? @"&%@=%@" : @"%@=%@", key, value];
  }];
  return queryString;
}

- (MSAIHTTPOperation *) operationWithURLRequest:(NSURLRequest*) request
                                   completion:(MSAINetworkCompletionBlock) completion {
  MSAIHTTPOperation *operation = [MSAIHTTPOperation operationWithRequest:request
  ];
  [operation setCompletion:completion];
  
  return operation;
}

- (void)getPath:(NSString *)path parameters:(NSDictionary *)params completion:(MSAINetworkCompletionBlock)completion {
  NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:params];
  MSAIHTTPOperation *op = [self operationWithURLRequest:request
                                            completion:completion];
  [self enqeueHTTPOperation:op];
}

- (void)postPath:(NSString *)path parameters:(NSDictionary *)params completion:(MSAINetworkCompletionBlock)completion {
  NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:params];
  MSAIHTTPOperation *op = [self operationWithURLRequest:request
                                            completion:completion];
  [self enqeueHTTPOperation:op];
}

- (void)enqeueHTTPOperation:(MSAIHTTPOperation *)operation {
  [self.operationQueue addOperation:operation];
}

- (NSUInteger)cancelOperationsWithPath:(NSString*)path method:(NSString*)method {
  NSUInteger cancelledOperations = 0;
  for(MSAIHTTPOperation *operation in self.operationQueue.operations) {
    NSURLRequest *request = operation.URLRequest;
    
    BOOL matchedMethod = NO;
    if ([request.HTTPMethod isEqualToString:method]) {
      matchedMethod = YES;
    }
    
    BOOL matchedPath = NO;
    if (path) {
      //method is not interesting here, we' just creating it to get the URL
      NSURL *url = [self requestWithMethod:@"GET" path:path parameters:nil].URL;
      matchedPath = [request.URL isEqual:url];
    }
    
    if (matchedPath || matchedMethod) {
      [operation cancel];
      ++cancelledOperations;
    }
  }
  return cancelledOperations;
}

- (NSUInteger)cancelAllOperations {
  NSUInteger cancelledOperations = 0;
  for(MSAIHTTPOperation *operation in self.operationQueue.operations) {
    [operation cancel];
    ++cancelledOperations;
  }
  return cancelledOperations;
}

- (NSOperationQueue *)operationQueue {
  if(nil == _operationQueue) {
    _operationQueue = [[NSOperationQueue alloc] init];
    _operationQueue.maxConcurrentOperationCount = 1;
  }
  return _operationQueue;
}

@end
