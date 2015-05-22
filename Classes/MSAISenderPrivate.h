#import "MSAIAppInsightsDelegate.h"
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
 *  Delegate that should be informed if sending was successful or failed.
 */
@property (nonatomic, weak) id<MSAIAppInsightsDelegate> delegate;

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

/**
 *  Configures the sender instance.
 *
 *  @param appClient    the app client used for sending the data
 *  @param endpointPath the endpoint url of the telemetry server
 *  @param delegate delegate that should be informed if sending was successful or failed
 */
- (void)configureWithAppClient:(MSAIAppClient *)appClient delegate:(nullable id<MSAIAppInsightsDelegate>) delegate;

///-----------------------------------------------------------------------------
/// @name Sending data
///-----------------------------------------------------------------------------

/**
 *  Triggers sending the saved data. Does nothing if nothing has been persisted, yet. This method should be called by MSAITelemetryMnager on app start.
 */
- (void)sendSavedData;

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
 *  Returnes a request for sending data to the telemetry sender.
 *
 *  @param data the data which should be sent
 *
 *  @return a request which contains the given data
 */
- (NSURLRequest *)requestForData:(NSData *)data;

/**
 *  Returns if data should be deleted based on a given status code.
 *
 *  @param statusCode the status code which is part of the response object
 *
 *  @return YES if data should be deleted, NO if the payload should be sent at a later time again.
 */
- (BOOL)shouldDeleteDataWithStatusCode:(NSInteger)statusCode;

@end
NS_ASSUME_NONNULL_END
