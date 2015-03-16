@class MSAIEnvelope;
@class MSAITelemetryContext;

@interface MSAISender ()

///-----------------------------------------------------------------------------
/// @name Initialize & configure shared instance
///-----------------------------------------------------------------------------

/**
*  The appClient is needed to create requests and send objects via an operation queue.
*/
@property (nonatomic, strong) MSAIAppClient *appClient;

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
- (void)configureWithAppClient:(MSAIAppClient *)appClient endpointPath:(NSString *)endpointPath;

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
 *  Returnes a request for sending data to the telemetry sender.
 *
 *  @param data the data which should be sent
 *  @param urlString url depending on payload
 *
 *  @return a request which contains the given data
 */
- (NSURLRequest *)requestForData:(NSData *)data urlString:(NSString *)urlString;

/**
 *  Convert a collection of envelope objects to array of dictionaries.
 *
 *  @param envelopeArray array of envelope objects
 *
 *  @return a json array of envelope objects
 */
- (NSArray *)jsonArrayFromArray:(NSArray *)envelopeArray;

@end
