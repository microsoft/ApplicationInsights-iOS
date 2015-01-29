@class MSAIEnvelope;
@class MSAITelemetryContext;

@interface MSAISender ()

///-----------------------------------------------------------------------------
/// @name Initialize & configure shared instance
///-----------------------------------------------------------------------------

/**
*  The appClient is needed to create requests and send objects via an operation queue.
*/
@property(nonatomic, strong)MSAIAppClient *appClient;

/**
 *  The endpoint url of the telemetry server.
 */
@property (nonatomic, strong)NSString *endpointPath;

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
/// @name Queue management
///-----------------------------------------------------------------------------

/**
 *  A queue which makes array operations thread safe.
 */
@property (nonatomic, strong) dispatch_queue_t dataItemsOperations;

/**
 *  An array for collecting data, which should be sent to the telemetry server.
 */
@property(nonatomic, strong) NSMutableArray *dataItemQueue;

/**
 *  Add metrics data to sender queue.
 *
 *  @param dataDict data which should be sent
 */
- (void)enqueueDataDict:(NSDictionary *)dataDict;

///-----------------------------------------------------------------------------
/// @name Batching
///-----------------------------------------------------------------------------

/**
 *  A timer source which is used to flush the queue after a cretain time.
 */
@property (nonatomic, strong) dispatch_source_t timerSource;

/**
 *  Starts the timer.
 */
- (void)startTimer;

/**
 *  Stops the timer if currently running.
 */
- (void)invalidateTimer;

/**
 *  Sends all enqueued events.
 */
- (void)flushSenderQueue;

/**
 *  Creates a HTTP operation and puts it to the queue.
 *
 *  @param request a request for sending a data object to the telemetry server
 */
- (void)sendRequest:(NSURLRequest *)request;

///-----------------------------------------------------------------------------
/// @name Helper
///-----------------------------------------------------------------------------

/**
 *  Returnes a request for sending data to the telemetry sender.
 *
 *  @param data the data which should be sent
 *
 *  @return a request which contains the given data.
 */
- (NSURLRequest *)requestForData:(NSData *)data;



@end
