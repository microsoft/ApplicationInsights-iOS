@class MSAIEnvelope;

@interface MSAISender ()

/**
 *  An array for collecting data, which should be sent to the telemetry server.
 */
@property(nonatomic, strong) NSMutableArray *dataItemQueue;

/**
 *  A queue which makes array operations thread safe.
 */
@property (nonatomic, strong) dispatch_queue_t dataItemsOperations;

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

/**
 *  <#Description#>
 *
 *  @param dataDict <#dataDict description#>
 */
- (void)enqueueDataDict:(NSDictionary *)dataDict;

/**
 *  Sends all enqueued events.
 */
- (void)flushSenderQueue;

/**
 *  Returnes a request for sending data to the telemetry sender.
 *
 *  @param data the data which should be sent
 *
 *  @return a request which contains the given data.
 */
- (NSURLRequest *)requestForData:(NSData *)data;

/**
 *  Creates a HTTP operation and puts it to the queue.
 *
 *  @param request a request for sending a data object to the telemetry server
 */
- (void)enqueueRequest:(NSURLRequest *)request;

@end
