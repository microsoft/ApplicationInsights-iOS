#import "MSAIApplication.h"
#import "MSAIDevice.h"
#import "MSAIOperation.h"
#import "MSAIInternal.h"
#import "MSAIUser.h"
#import "MSAISession.h"
#import "MSAILocation.h"

@interface MSAITelemetryContext()

@property (readonly) long acquisitionMs;

@property (readonly) long renewalMs;

/**
 *  The path to the telemetry endpoint.
 */
@property(nonatomic, strong) NSString *endpointPath;

/**
 *  The instrumentation key of the app.
 */
@property(nonatomic, strong) NSString *instrumentationKey;

/**
 *  The application context.
 */
@property(nonatomic, strong) MSAIApplication *application;

/**
 *  The device context.
 */
@property (nonatomic, strong)MSAIDevice *device;

/**
 *  The location context.
 */
@property (nonatomic, strong)MSAILocation *location;

/**
 *  The session context.
 */
@property (nonatomic, strong)MSAISession *session;

/**
 *  The user context.
 */
@property (nonatomic, strong)MSAIUser *user;

/**
 *  The internal context.
 */
@property (nonatomic, strong)MSAIInternal *internal;

/**
 *  The operation context.
 */
@property (nonatomic, strong)MSAIOperation *operation;

/**
 *  Initializes a telemetry context.
 *
 *  @param instrumentationKey the instrumentation key of the app
 *  @param endpointPath       the path to the telemetry endpoint
 *  @param applicationContext the application context object
 *  @param deviceContext      the device context object
 *  @param locationContext    the location context object
 *  @param sessionContext     the session context object
 *  @param userContext        the user context object
 *  @param internalContext    the internal context object
 *  @param operationContext   the operation context object
 *
 *  @return the telemetry context
 */
- (instancetype)initWithInstrumentationKey:(NSString *)instrumentationKey
                              endpointPath:(NSString *)endpointPath
                        applicationContext:(MSAIApplication *)applicationContext
                             deviceContext:(MSAIDevice *)deviceContext
                           locationContext:(MSAILocation *)locationContext
                            sessionContext:(MSAISession *)sessionContext
                               userContext:(MSAIUser *)userContext
                           internalContext:(MSAIInternal *)internalContext
                          operationContext:(MSAIOperation *)operationContext;

/**
 *  Returns context objects as dictionary.
 *
 *  @return a dictionary containing all context fields
 */
- (MSAIOrderedDictionary *)contextDictionary;

///-----------------------------------------------------------------------------
/// @name Session management
///-----------------------------------------------------------------------------

- (void)updateSessionContext;

- (void)writeSessionDefaultsWithSessionId:(NSString *)sessionId acquisitionTime:(long)acquisitionTime;

- (void)updateSessionFromSessionDefaults;

- (BOOL)isFirstSession;

- (void)createNewSessionWithCurrentDateTime:(long)dateTime;

- (void)renewSessionWithCurrentDateTime:(long)dateTime;

@end
