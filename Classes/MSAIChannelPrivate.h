#import <Foundation/Foundation.h>
#import "MSAIHTTPOperation.h"

@class MSAIEnvelope;
@class MSAITelemetryContext;
@class MSAIAppClient;
@class MSAITelemetryContext;
@class MSAITelemetryData;
@class MSAISender;
@class MSAICrashData;

@interface MSAIChannel ()

///-----------------------------------------------------------------------------
/// @name Initialisation
///-----------------------------------------------------------------------------

+ (instancetype)sharedChannel;

/**
 *  The context object, which contains information about current session, the device, the user etc.
 */
@property(nonatomic, strong, readonly)MSAITelemetryContext *telemetryContext;

/**
 *  The sender instance.
 */
@property(nonatomic, strong, readonly)MSAISender *sender;

/**
 *  Initializes the telemetry channel.
 *
 *  @param appClient     the app client for sending data
 *  @param clientContext information about the client and the AI account
 *
 *  @return a channel instance.
 */
- (instancetype)configureWithAppClient:(MSAIAppClient *) appClient telemetryContext:(MSAITelemetryContext *)telemetryContext;

///-----------------------------------------------------------------------------
/// @name Enqueue data
///-----------------------------------------------------------------------------

/**
 *  Sends out telemetry data to the server.
 *
 *  @param dataItem the data object, which should be sent to the telemetry server
 */
- (void)sendDataItem:(MSAITelemetryData *)dataItem;

- (void)sendCrashItem:(MSAICrashData *)crashItem withCompletionBlock:(MSAINetworkCompletionBlock)completion;

///-----------------------------------------------------------------------------
/// @name Helper
///-----------------------------------------------------------------------------

/**
 *  Creates a dictionary out of the given telemetry data and context information.
 *
 *  @param dataItem the telemetry data to send
 *
 *  @return return a dictionary which contains the telemetry data and context information
 */
- (NSDictionary *)dictionaryFromDataItem:(MSAITelemetryData *)dataItem;

/**
 *  Returns the formatted string for a given date.
 *
 *  @param date the date to be converted to a string
 *
 *  @return the string representation for a given date
 */
- (NSString *)dateStringForDate:(NSDate *)date;

@end
