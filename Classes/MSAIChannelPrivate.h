#import <Foundation/Foundation.h>
@class MSAIEnvelope;

@interface MSAIChannelPrivate ()

/**
 *  Create a request for sending a data object to the telemetry server.
 *
 *  @param dataItem the data object, which should be sent to the server
 *
 *  @return a request for sending a data object to the telemetry server
 */
- (NSURLRequest *)requestForDataItem:(MSAIEnvelope *)dataItem;

/**
 *  Creates a HTTP operation and puts it to the queue.
 *
 *  @param request a request for sending a data object to the telemetry server
 */
- (void)enqueueRequest:(NSURLRequest *)request;

/**
 *  Returns the current date as string.
 *
 *  @return a string with the current date
 */
- (NSString *)dateString;

@end