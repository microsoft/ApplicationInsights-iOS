#import <Foundation/Foundation.h>

@interface MSAIAppInsights : NSObject

///-----------------------------------------------------------------------------
/// @name Setting up and start an MSAIAppInsights
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
 *  @param instrumentationKey the instrumentationKey of your AppInsights component
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
/// @name Getting the shared MSAIAppInsights instance
///-----------------------------------------------------------------------------

/**
 * Returns a shared MSAIManager object.
 *
 * @return a singleton MSAIManager instance ready use
 */
+ (MSAIAppInsights *)sharedInstance;

///-----------------------------------------------------------------------------
/// @name Setting up and start an MSAIAppInsights instance
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
 *  @param instrumentationKey the instrumentationKey of your AppInsights component
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
/// @name Configuring MSAIAppInsights
///-----------------------------------------------------------------------------

/**
 * Defines the server URL to send data to or request data from. By default this is set 
 * to the AppInsights servers and there rarely should be a need to modify that.
 *
 * @warning This property needs to be set before calling `startManager`. 
 * Since there are several endpoints for different data types, you should not set it for now.
 */
@property (nonatomic, strong) NSString *serverURL;

/**
 * Flag which determines whether the Crash Manager should be disabled. If this flag is
 * enabled, then crash reporting is disabled and no crashes will be send. Please note 
 * that the Crash Manager instance will be initialized anyway, but crash report
 * handling (signal and uncaught exception handlers) will **not** be registered.
 *
 * @warning This property needs to be set before calling `start`
 */
@property (nonatomic, getter = isCrashManagerDisabled) BOOL crashManagerDisabled;

/**
 *  Enable (NO) or disable (YES) the crash manager. This should be called before `start`.
 *
 *  @param crashManagerDisabled Flag which determines whether the Crash Manager should be disabled
 */
+ (void)setCrashManagerDisabled:(BOOL)crashManagerDisabled;

/**
 * Flag the determines whether the Metrics Manager should be disabled. 
 * If this flag is enabled, then metrics collection is disabled and metrics data will
 * not be collected and send.
 *
 * @return YES, if manager is disabled
 *
 * @default NO
 * @see MSAIMetricsManager
 * @warning This property needs to be set before calling `start`
 */
@property (nonatomic, getter = isMetricsManagerDisabled) BOOL metricsManagerDisabled;

/**
 *  Enable (NO) or disable (YES) the metrics manager. This should be called before `start`.
 *
 *  @param metricsManagerDisabled Flag which determines whether the Metrics Manager should be disabled
 */
+ (void)setMetricsManagerDisabled:(BOOL)metricsManagerDisabled;

/**
 * Flag the determines whether collecting page views automatically should be disabled.
 * If YES, auto page view collection is disabled. Y
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
/// @name Testing integration
///-----------------------------------------------------------------------------

/**
 * Pings the server with the AppInsights app identifiers used for initialization.
 * Call this method once for debugging purposes to test if your SDK setup code
 * reaches the server successfully.
 * Once invoked, check the apps page on AppInsights for a verification.
 * If you setup the SDK with a beta and live identifier, a call to both app IDs will be done.
 * This call is ignored if the app is running in the App Store!.
 */
+ (void)testIdentifier;

/**
 * Pings the server with the AppInsights app identifiers used for initialization.
 * Call this method once for debugging purposes to test if your SDK setup code
 * reaches the server successfully.
 * Once invoked, check the apps page on AppInsights for a verification.
 * If you setup the SDK with a beta and live identifier, a call to both app IDs will be done.
 * This call is ignored if the app is running in the App Store!.
 */
- (void)testIdentifier;

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
