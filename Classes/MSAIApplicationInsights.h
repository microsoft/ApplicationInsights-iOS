#import <Foundation/Foundation.h>
#import "MSAINullability.h"
#import "MSAIUser.h"

NS_ASSUME_NONNULL_BEGIN
/**
 This is the main class to setup, configure and start the Application Insights SDK.
 */
@interface MSAIApplicationInsights : NSObject

///-----------------------------------------------------------------------------
/// @name Setting up and start an MSAIApplicationInsights
///-----------------------------------------------------------------------------

/**
 * Configures the manager with the instrumentation key from the info.plist and
 * initializes all modules. This method should be called before calling `start`.
 */
+ (void)setup;

/**
 * Configures the manager with a instrumentation key and initializes all modules. 
 * This method should be called before calling `start`.
 *
 *  @param instrumentationKey the instrumentationKey of your Application Insights component
 */
+ (void)setupWithInstrumentationKey:(NSString *)instrumentationKey;

/**
 * Starts the manager and runs all modules. Call this after initializing the manager
 * and setting up all modules.
 *
 * @see setup;
 */
+ (void)start;

///-----------------------------------------------------------------------------
/// @name Getting the shared MSAIApplicationInsights instance
///-----------------------------------------------------------------------------

/**
 * Returns a shared MSAIManager object.
 *
 * @return a singleton MSAIManager instance ready use
 */
+ (MSAIApplicationInsights *)sharedInstance;

///-----------------------------------------------------------------------------
/// @name Setting up and start an MSAIApplicationInsights instance
///-----------------------------------------------------------------------------

/**
 * Configures the manager with the instrumentation key from the info.plist and
 * initializes all modules. This method should be called before calling `start`.
 */
- (void)setup;

/**
 * Configures the manager with a instrumentation key and initializes all modules.
 * This method should be called before calling `start`.
 *
 *  @param instrumentationKey the instrumentationKey of your Application Insights component
 */
- (void)setupWithInstrumentationKey:(NSString *)instrumentationKey;

/**
 * Starts the manager and runs all modules. Call this after initializing the manager
 * and setting up all modules.
 *
 * @see setup;
 */
- (void)start;

///-----------------------------------------------------------------------------
/// @name Configuring MSAIApplicationInsights
///-----------------------------------------------------------------------------

/**
 * Defines the server URL to send data to or request data from. By default this is set 
 * to the Application Insights servers and there rarely should be a need to modify that.
 * If you set your custom server URL, make sure you set the full URL (e.g. https://yourdomain.com/track/)
 * @warning This property needs to be set before calling `start`.
 */
@property (nonatomic, copy) NSString *serverURL;

#if MSAI_FEATURE_TELEMETRY
/**
 * Flag that determines whether the Telemetry Manager should be disabled.
 * If this flag is enabled, then telemetry collection is disabled and telemetry data will
 * not be collected and send.
 *
 * @return YES, if manager is disabled
 *
 * @default NO
 * @see MSAITelemetryManager
 * @warning This property needs to be set before calling `start`
 */
@property (nonatomic, getter = isTelemetryManagerDisabled) BOOL telemetryManagerDisabled;

/**
 *  Enable (NO) or disable (YES) the telemetry manager. This should be called before `start`.
 *
 *  @param telemetryManagerDisabled Flag which determines whether the Telemetry Manager should be disabled
 */
+ (void)setTelemetryManagerDisabled:(BOOL)telemetryManagerDisabled;

/**
 * Flag that determines whether collecting page views automatically should be disabled.
 * If YES, auto page view collection is disabled.
 *
 * @return YES, if manager is disabled
 *
 * @default NO
 * @warning This property needs to be set before calling `start`
 */
@property (nonatomic, getter = isAutoPageViewTrackingDisabled) BOOL autoPageViewTrackingDisabled;

/**
 *  Enable (NO) or disable (YES) auto collection of page views. This should be called before `start`.
 *
 *  @param autoPageViewTrackingDisabled Flag which determines whether the page view collection should be disabled
 */
+ (void)setAutoPageViewTrackingDisabled:(BOOL)autoPageViewTrackingDisabled;

#endif /* MSAI_FEATURE_TELEMETRY */

/**
 *  Flag that determines whether sessions will automatically be renewed when the app starts and goes to the background for more than 20 seconds.
 *  If YES, sessions are not automatically renewed and the developer has to manually trigger a session renewal or set a specific session ID.
 *
 *  @return YES, if automatic session management is disabled.
 *
 *  @default NO
 * @warning This property needs to be set before calling `start` 
 */
@property (nonatomic, getter=isAutoSessionManagementDisabled) BOOL autoSessionManagementDisabled;

/**
 *  Disable (YES) automatic session management and renewal.
 *
 *  @param autoSessionManagementDisabled Flag that determines whether automatic session management should be disabled.
 */
+ (void)setAutoSessionManagementDisabled:(BOOL)autoSessionManagementDisabled;

/**
 *  Use this method to configure the current user's context.
 *
 *  @param userConfigurationBlock This block gets the current user as an input.
 *  Within the block you can update the user object's values to up-to-date.
 */
+ (void)setUserWithConfigurationBlock:(void (^)(MSAIUser *user))userConfigurationBlock;

/**
 *  Use this method to configure the current user's context.
 *
 *  @param userConfigurationBlock This block gets the current user as an input.
 *  Within the block you can update the user object's values to up-to-date.
 */
- (void)setUserWithConfigurationBlock:(void (^)(MSAIUser *user))userConfigurationBlock;

/**
 *  Manually trigger a new session start.
 */
+ (void)startNewSession;

/**
 *  Manually trigger a new session start.
 */
- (void)startNewSession;

/**
 *  Set the time which the app has to have been in the background for before a new session is started.
 *  This time is only used when automatic session management is not disabled.
 *
 *  @param appBackgroundTimeBeforeSessionExpires The time in seconds the app has to be in the background before a new session is started.
 */
+ (void)setAppBackgroundTimeBeforeSessionExpires:(NSUInteger)appBackgroundTimeBeforeSessionExpires;

/**
 *  Set the time which the app has to have been in the background for before a new session is started.
 *  This time is only used when automatic session management is not disabled.
 *
 *  @param appBackgroundTimeBeforeSessionExpires The time in seconds the app has to be in the background before a new session is started.
 */
- (void)setAppBackgroundTimeBeforeSessionExpires:(NSUInteger)appBackgroundTimeBeforeSessionExpires;

/**
 *  This starts a new session with the given session ID. 
 *
 *  @param sessionId The session ID which should be attached to all future telemetry events.
 *
 *  @warning Using this method automatically disables automatic session management!
 *  @see autoSessionManagementDisabled
 */
+ (void)renewSessionWithId:(NSString *)sessionId;

/**
 *  This starts a new session with the given session ID.
 *
 *  @param sessionId The session ID which should be attached to all future telemetry events.
 *
 *  @warning Using this method automatically disables automatic session management!
 *  @see autoSessionManagementDisabled
 */
- (void)renewSessionWithId:(NSString *)sessionId;

///-----------------------------------------------------------------------------
/// @name Environment
///-----------------------------------------------------------------------------

/**
 * Flag that determines whether the application is installed and running
 * from an App Store installation. Returns _YES_ if the app is installed and running 
 * from the App Store or _NO_ if the app is installed via debug, ad-hoc or enterprise 
 * distribution
 */
@property (nonatomic, readonly, getter=isAppStoreEnvironment) BOOL appStoreEnvironment;

///-----------------------------------------------------------------------------
/// @name Debug Logging
///-----------------------------------------------------------------------------

/**
 * Flag which determines additional logging output should be generated by the manager
 * and all modules. This is ignored if the app is running in the App Store and
 * reverts to the default value in that case. Default is NO.
 *
 * @warning This property needs to be set before calling `startManager`
 */
@property (nonatomic, assign, getter=isDebugLogEnabled) BOOL debugLogEnabled;

///-----------------------------------------------------------------------------
/// @name Getting SDK meta data
///-----------------------------------------------------------------------------

/**
 Returns the SDK Version (CFBundleShortVersionString).
 */
+ (NSString *)version;

/**
 Returns the SDK Version (CFBundleShortVersionString).
 */
- (NSString *)version;

/**
 Returns the SDK Build (CFBundleVersion) as a string.
 */
+ (NSString *)build;

/**
 Returns the SDK Build (CFBundleVersion) as a string.
 */
- (NSString *)build;

@end
NS_ASSUME_NONNULL_END
