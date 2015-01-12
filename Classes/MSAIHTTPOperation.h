#import <Foundation/Foundation.h>

@class MSAIHTTPOperation;
typedef void (^MSAINetworkCompletionBlock)(MSAIHTTPOperation * operation, NSData* data, NSError* error);

@interface MSAIHTTPOperation : NSOperation

+ (instancetype) operationWithRequest:(NSURLRequest *) urlRequest;

@property (nonatomic, readonly) NSURLRequest *URLRequest;

//the completion is only called if the operation wasn't cancelled
- (void) setCompletion:(MSAINetworkCompletionBlock) completionBlock;

@property (nonatomic, readonly) NSHTTPURLResponse *response;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSError *error;

@end
