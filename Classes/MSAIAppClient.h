#import <Foundation/Foundation.h>
#import "MSAIHTTPOperation.h"

MSAI_ASSUME_NONNULL_BEGIN
/**
 *  Generic ApplicationInsights API client
 */
@interface MSAIAppClient : NSObject

/**
 *	designated initializer
 *
 *	@param	baseURL	the baseURL of the ApplicationInsights instance
 */
- (instancetype)initWithBaseURL:(NSURL*)baseURL;

/**
 *	baseURL to which relative paths are appended
 */
@property (nonatomic, strong) NSURL *baseURL;

/**
 *	creates an NRURLRequest for the given method and path by using
 *  the internally stored baseURL.
 *
 *	@param	method	the HTTPMethod to check, must not be nil
 *	@param	params	parameters for the request (only supported for GET and POST for now)
 *	@param	path	path to append to baseURL. can be nil in which case "/" is appended
 *
 *	@return	an NSMutableURLRequest for further configuration
 */
- (NSMutableURLRequest *)requestWithMethod:(NSString*)method
                                      path:(MSAI_NULLABLE NSString *)path
                                parameters:(MSAI_NULLABLE NSDictionary *)params;

/**
 *	Creates an operation for the given NSURLRequest
 *
 *	@param	request	the request that should be handled
 *	@param  queue Queue on which the completion block will be executed.
 *	@param	completion	completionBlock that is called once the operation finished
 *
 *	@return	operation, which can be queued via enqueueHTTPOperation:
 */
- (MSAIHTTPOperation *)operationWithURLRequest:(NSURLRequest *)request queue:(dispatch_queue_t)queue completion:(MSAI_NULLABLE MSAINetworkCompletionBlock)completion;

/**
 *	Creates an operation for the given path, and enqueues it
 *
 *	@param	path	the request path to check
 *	@param	params parameters for the request
 *	@param	completion	completionBlock that is called once the operation finished. 
 *          The block is executed on the main queue.
 *
 */
- (void)getPath:(NSString*)path
     parameters:(MSAI_NULLABLE NSDictionary *)params
     completion:(MSAI_NULLABLE MSAINetworkCompletionBlock)completion;

/**
 *	Creates an operation for the given path, and enqueues it
 *
 *	@param	path	the request path to check
 *	@param	params parameters for the request
 *	@param	completion	completionBlock that is called once the operation finished.
 *          The block is executed on the main queue
 *
 */
- (void)postPath:(NSString*)path
      parameters:(MSAI_NULLABLE NSDictionary *)params
      completion:(MSAI_NULLABLE MSAINetworkCompletionBlock)completion;
/**
 *	adds the given operation to the internal queue
 *
 *	@param	operation	operation to add
 */
- (void)enqeueHTTPOperation:(MSAIHTTPOperation *)operation;

/**
 *	cancels the specified operations
 *
 *	@param	path	the path which operation should be cancelled.
 *	@param	method	the method which operations to cancel.
 *
 *  @return number of operations cancelled
 *
 *  @see cancelAllOperations
 */
- (NSUInteger)cancelOperationsWithPath:(MSAI_NULLABLE NSString*)path
                                method:(MSAI_NULLABLE NSString*)method;

/**
 *  cancels all current operations
 *
 *  @returns number of operations cancelled
 *
 *  @see cancelOperationsWithPath:method:
 */
- (NSUInteger)cancelAllOperations;
 
/**
 *	Access to the internal operation queue
 */
@property (nonatomic, strong) NSOperationQueue *operationQueue;

#pragma mark - Helpers
/**
 *	create a post body from the given value, key and boundary. This is a convenience call to 
 *  dataWithPostValue:forKey:contentType:boundary and aimed at NSString-content.
 *
 *	@param	value	-
 *	@param	key	-
 *	@param	boundary	-
 *
 *	@return	NSData instance configured to be attached on a (post) URLRequest
 */
+ (NSData *)dataWithPostValue:(NSString *)value forKey:(NSString *)key boundary:(NSString *)boundary;

/**
 *	create a post body from the given value, key and boundary and content type.
 *
 *	@param	value	-
 *	@param	key	-
 *  @param contentType -
 *	@param	boundary	-
 *	@param	filename	-
 *
 *	@return	NSData instance configured to be attached on a (post) URLRequest
 */
+ (NSData *)dataWithPostValue:(NSData *)value forKey:(NSString *)key contentType:(NSString *)contentType boundary:(NSString *)boundary filename:(MSAI_NULL_UNSPECIFIED NSString *)filename;

@end
MSAI_ASSUME_NONNULL_END
