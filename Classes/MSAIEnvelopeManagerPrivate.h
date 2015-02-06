@class MSAIEnvelope;
@class MSAITelemetryData;
@class MSAITelemetryContext;

@interface MSAIEnvelopeManager()

/**
 *  The context object, which contains information about current session, the device, the user etc.
 */
@property(nonatomic, strong, readonly)MSAITelemetryContext *telemetryContext;

/**
 *  Initializes the telemetry channel.
 *
 *  @param telemetryContext information about the client and the AI account
 */
- (void)configureWithTelemetryContext:(MSAITelemetryContext *)telemetryContext;

/**
 *  Returns the formatted string for a given date.
 *
 *  @param date the date to be converted to a string
 *
 *  @return the string representation for a given date
 */
- (NSString *)dateStringForDate:(NSDate *)date;

- (MSAIEnvelope *)envelopeForTelemetryData:(MSAITelemetryData *)telemetryData;

@end
