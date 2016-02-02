#import <Foundation/Foundation.h>
#import "MSAIEnvelopeManager.h"

@class MSAIEnvelope;
@class MSAITelemetryData;
@class MSAITelemetryContext;
@class MSAIPLCrashReport;

NS_ASSUME_NONNULL_BEGIN
@interface MSAIEnvelopeManager()

///-----------------------------------------------------------------------------
/// @name Initialize and configure singleton instance
///-----------------------------------------------------------------------------

/**
 *  The context object, which contains information about current session, the device, the user etc.
 */
@property(nonatomic, strong, readonly)MSAITelemetryContext *telemetryContext;

/**
 *  Get the singleton instance.
 *
 *  @return the singleton instance
 */
+ (instancetype)sharedManager;

/**
 *  Configure the manager with a given context object.
 *
 *  @param telemetryContext information about the client and the AI account
 */
- (void)configureWithTelemetryContext:(MSAITelemetryContext *)telemetryContext;

///-----------------------------------------------------------------------------
/// @name Create envelope objects
///-----------------------------------------------------------------------------

/**
 *  Creates an envelope object with the current context information, but without any base data.
 *
 *  @return the created envelope object
 */
- (MSAIEnvelope *)envelope;

/**
 *  Creates an envelope object with the current context information and base data.
 *
 *  @param telemetryData the base data for the envelope
 *
 *  @return the created envelope object
 */
- (MSAIEnvelope *)envelopeForTelemetryData:(MSAITelemetryData *)telemetryData;

@end
NS_ASSUME_NONNULL_END
