#import "MSAITelemetryContext.h"
#import "MSAIApplication.h"
#import "MSAIDevice.h"
#import "MSAIOperation.h"
#import "MSAIInternal.h"
#import "MSAIUser.h"
#import "MSAISession.h"
#import "MSAILocation.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSAITelemetryContext()

///-----------------------------------------------------------------------------
/// @name Initialisation
///-----------------------------------------------------------------------------

/**
*  A queue which makes array operations thread safe.
*/
@property (nonatomic, strong) dispatch_queue_t operationsQueue;

/**
 *  The application context.
 */
@property(nonatomic, strong, readonly) MSAIApplication *application;

/**
 *  The device context.
 */
@property (nonatomic, strong, readonly)MSAIDevice *device;

/**
 *  The location context.
 */
@property (nonatomic, strong, readonly)MSAILocation *location;

/**
 *  The session context.
 */
@property (nonatomic, strong, readonly)MSAISession *session;

/**
 *  The user context.
 */
@property (nonatomic, strong, readonly)MSAIUser *user;

/**
 *  The internal context.
 */
@property (nonatomic, strong, readonly)MSAIInternal *internal;

/**
 *  The operation context.
 */
@property (nonatomic, strong, readonly)MSAIOperation *operation;
 
/**
 *  Initializes a telemetry context.
 *
 *  @param instrumentationKey the instrumentation key of the app.
 *
 *  @return the telemetry context
 */
- (instancetype)initWithInstrumentationKey:(NSString *)instrumentationKey;

///-----------------------------------------------------------------------------
/// @name Users
///-----------------------------------------------------------------------------

/**
 *  Use this method to configure the current  context.
 *
 *  @param telemetryContextConfigurationBlock block gets the current context as an input.
 *  Within the block you can update the context object's values to up-to-date.
 */
- (void)setTelemetryContextWithConfigurationBlock:(void (^)(MSAITelemetryContext *telemetryContext))telemetryContextConfigurationBlock;

/**
 *  Use this method to configure the current user's context.
 *
 *  @param userConfigurationBlock This block gets the current user as an input.
 *  Within the block you can update the user object's values to up-to-date.
 */
- (void)setUserWithConfigurationBlock:(void (^)(MSAIUser *user))userConfigurationBlock;

///-----------------------------------------------------------------------------
/// @name Network status
///-----------------------------------------------------------------------------

/**
 *  Get current network type and register for updates.
 */
- (void)configureNetworkStatusTracking;

///-----------------------------------------------------------------------------
/// @name Helper
///-----------------------------------------------------------------------------

/**
 *  Returns context objects as dictionary.
 *
 *  @return a dictionary containing all context fields
 */
- (MSAIOrderedDictionary *)contextDictionary;

@end
NS_ASSUME_NONNULL_END
