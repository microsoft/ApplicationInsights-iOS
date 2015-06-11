@class MSAIEnvelope;
@class MSAITelemetryContext;

NS_ASSUME_NONNULL_BEGIN
@interface MSAISender ()

///-----------------------------------------------------------------------------
/// @name Initialize & configure shared instance
///-----------------------------------------------------------------------------

/**
*  The appClient is needed to create requests and send objects via an operation queue.
*/
@property (nonatomic, strong) MSAIAppClient *appClient;

/**
 *  A queue which is used to handle MSAIHTTPOperation completion blocks.
 */
@property (nonatomic, strong) dispatch_queue_t senderQueue;

/**
 *  The endpoint url of the telemetry server.
 */
@property (nonatomic, strong) NSString *endpointPath;

/**
 *  The max number of request that can run at a time.
 */
@property NSUInteger maxRequestCount;

/**
 *  The number of requests that are currently running.
 */
@property NSUInteger runningRequestsCount;

/**
*  Returns a shared MSAISender object.
*
*  @return A singleton MSAISender instance ready use
*/
+ (instancetype)sharedSender;

/**
 *  Configures the sender instance.
 *
 *  @param appClient    the app client used for sending the data
 *  @param endpointPath the endpoint url of the telemetry server
 */
- (void)configureWithAppClient:(MSAIAppClient *)appClient;

///-----------------------------------------------------------------------------
/// @name Sending data
///-----------------------------------------------------------------------------

/**
 *  Creates a HTTP operation and puts it to the queue.
 *
 *  @param request a request for sending a data object to the telemetry server
 *  @param path path to the file which should be sent
 */
- (void)sendRequest:(NSURLRequest *)request path:(NSString *)path;

///-----------------------------------------------------------------------------
/// @name Helper
///-----------------------------------------------------------------------------

/**
 *  Returns a request for sending data to the telemetry sender.
 *
 *  @param data the data which should be sent
 *
 *  @return a request which contains the given data
 */
- (NSURLRequest *)requestForData:(NSData *)data withContentType:(NSString *)contentType;

/**
 *  Returns if data should be deleted based on a given status code.
 *
 *  @param statusCode the status code which is part of the response object
 *
 *  @return YES if data should be deleted, NO if the payload should be sent at a later time again.
 */
- (BOOL)shouldDeleteDataWithStatusCode:(NSInteger)statusCode;

/**
 *  This method tries to detect whether the given data object is regular JSON or JSON Stream and returns the appropriate HTTP content type.
 *
 *  @param data The data object whose content type should be returned.
 *
 *  @returns "application/json" if the data is regular JSON or "application/x-json-stream" if it is JSON Stream. Defaults to "application/json".
 */
- (NSString *)contentTypeForData:(NSData *)data;

@end
NS_ASSUME_NONNULL_END
