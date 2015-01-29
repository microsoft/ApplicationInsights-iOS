#import "MSAIApplication.h"
#import "MSAIDevice.h"
#import "MSAIOperation.h"
#import "MSAIInternal.h"
#import "MSAIUser.h"
#import "MSAISession.h"
#import "MSAILocation.h"

@interface MSAITelemetryContext()

///-----------------------------------------------------------------------------
/// @name Initialisation
///-----------------------------------------------------------------------------

/**
 *  The path to the telemetry endpoint.
 */
@property(nonatomic, strong, readonly) NSString *endpointPath;

/**
 *  The instrumentation key of the app.
 */
@property(nonatomic, strong, readonly) NSString *instrumentationKey;


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

///-----------------------------------------------------------------------------
/// @name Session
///-----------------------------------------------------------------------------

/**
 *  A reference to the userDefaults being used to store values
 */
@property(nonatomic, weak) NSUserDefaults *userDefaults;

/**
 *  Renews or even creates a new session if needed.
 */
- (void)updateSessionContext;

/**
 *  Checks if current session is the first one.
 *
 *  @return YES if current session has not been renewed or replaced by a new one
 */
- (BOOL)isFirstSession;

/**
 *  Creates a brand new session.
 */
- (void)createNewSession;

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
