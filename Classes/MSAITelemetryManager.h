#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol MSAITelemetryManagerDelegate;

@class MSAIBaseManager;
@class MSAICrashManager;
@class MSAIMetricsManager;
/** 
 The AppInsightsSDK manager. Responsible for setup and management of all components
 
 This is the principal SDK class. It represents the entry point for the AppInsightsSDK. The main promises of the class are initializing the SDK modules, providing access to global properties and to all modules. Initialization is divided into several distinct phases:
 
 1. Setup the [AppInsights](http://hockeyapp.net/) app identifier and the optional delegate: This is the least required information on setting up the SDK and using it. It does some simple validation of the app identifier and checks if the app is running from the App Store or not.
 2. Provides access to the SDK modules `MSAICrashManager`, `MSAIUpdateManager`, and `MSAIFeedbackManager`. This way all modules can be further configured to personal needs, if the defaults don't fit the requirements.
 3. Configure each module.
 4. Start up all modules.
 
 The SDK is optimized to defer everything possible to a later time while making sure e.g. crashes on startup can also be caught and each module executes other code with a delay some seconds. This ensures that applicationDidFinishLaunching will process as fast as possible and the SDK will not block the startup sequence resulting in a possible kill by the watchdog process.

 All modules do **NOT** show any user interface if the module is not activated or not integrated.
 `MSAICrashManager`: Shows an alert on startup asking the user if he/she agrees on sending the crash report, if `[MSAICrashManager crashManagerStatus]` is set to `MSAICrashManagerStatusAlwaysAsk` (default)
 `MSAIUpdateManager`: Is automatically deactivated when the SDK detects it is running from a build distributed via the App Store. Otherwise if it is not deactivated manually, it will show an alert after startup informing the user about a pending update, if one is available. If the user then decides to view the update another screen is presented with further details and an option to install the update.
 `MSAIFeedbackManager`: If this module is deactivated or the user interface is nowhere added into the app, this module will not do anything. It will not fetch the server for data or show any user interface. If it is integrated, activated, and the user already used it to provide feedback, it will show an alert after startup if a new answer has been received from the server with the option to view it.
 
 Example:
 
    [[MSAITelemetryManager sharedManager]
      configureWithInstrumentationKey:@"<InstrumentationKeyFromAppInsights>"
                     delegate:nil];
    [[MSAITelemetryManager sharedManager] startManager];
 
 @warning The SDK is **NOT** thread safe and has to be set up on the main thread!
 
 @warning Most properties of all components require to be set **BEFORE** calling`startManager`!

 */

@interface MSAITelemetryManager : NSObject

#pragma mark - Public Methods

///-----------------------------------------------------------------------------
/// @name Initialization
///-----------------------------------------------------------------------------

/**
 Returns a shared MSAITelemetryManager object
 
 @return A singleton MSAITelemetryManager instance ready use
 */
+ (MSAITelemetryManager *)sharedMSAIManager;


/**
 Initializes the manager with a particular app identifier
 
 Initialize the manager with a AppInsights app identifier.
 
    [[MSAITelemetryManager sharedMSAIManager]
      configureWithInstrumentationKey:@"<instrumentationKeyFromApplicationInsights>"];
 
 @see configureWithInstrumentationKey:delegate:
 @see configureWithBetaIdentifier:liveIdentifier:delegate:
 @see startManager
 @param instrumentationKey The app identifier that should be used.
 */
- (void)configureWithInstrumentationKey:(NSString *)instrumentationKey;


/**
 Initializes the manager with a particular app identifier and delegate
 
 Initialize the manager with a AppInsights app identifier and assign the class that
 implements the optional protocols `MSAITelemetryManagerDelegate`, `MSAICrashManagerDelegate` or
 `MSAIUpdateManagerDelegate`.
 
    [[MSAITelemetryManager sharedManager]
      configureWithIdentifier:@"<InstrumentationKeyFromAppInsights>"
                     delegate:nil];

 @see configureWithInstrumentationKey:
 @see configureWithBetaIdentifier:liveIdentifier:delegate:
 @see startManager
 @see MSAITelemetryManagerDelegate
 @see MSAICrashManagerDelegate
 @see MSAIUpdateManagerDelegate
 @see MSAIFeedbackManagerDelegate
 @param instrumentationKey The app identifier that should be used.
 @param delegate `nil` or the class implementing the option protocols
 */
- (void)configureWithInstrumentationKey:(NSString *)instrumentationKey delegate:(id<MSAITelemetryManagerDelegate>)delegate;


/**
 Starts the manager and runs all modules
 
 Call this after configuring the manager and setting up all modules.
 
 @see configureWithInstrumentationKey:delegate:
 @see configureWithBetaIdentifier:liveIdentifier:delegate:
 */
- (void)startManager;


#pragma mark - Public Properties

///-----------------------------------------------------------------------------
/// @name Modules
///-----------------------------------------------------------------------------


/**
 Set the delegate
 
 Defines the class that implements the optional protocol `MSAITelemetryManagerDelegate`.
 
 The delegate will automatically be propagated to all components. There is no need to set the delegate
 for each component individually.
 
 @warning This property needs to be set before calling `startManager`
 
 @see MSAITelemetryManagerDelegate
 @see MSAICrashManagerDelegate
 @see MSAIUpdateManagerDelegate
 @see MSAIFeedbackManagerDelegate
 */
@property (nonatomic, weak) id<MSAITelemetryManagerDelegate> delegate;


/**
 Defines the server URL to send data to or request data from
 
 By default this is set to the AppInsights servers and there rarely should be a
 need to modify that.
 
 @warning This property needs to be set before calling `startManager`
 */
@property (nonatomic, strong) NSString *serverURL;


/**
 Reference to the initialized MSAICrashManager module

 Returns the MSAICrashManager instance initialized by MSAITelemetryManager
 
 @see configureWithInstrumentationKey:delegate:
 @see startManager
 @see disableCrashManager
 */
@property (nonatomic, strong, readonly) MSAICrashManager *crashManager;


/**
 Flag the determines whether the Crash Manager should be disabled
 
 If this flag is enabled, then crash reporting is disabled and no crashes will
 be send.
 
 Please note that the Crash Manager instance will be initialized anyway, but crash report
 handling (signal and uncaught exception handlers) will **not** be registered.

 @warning This property needs to be set before calling `startManager`

 *Default*: _NO_
 @see crashManager
 */
@property (nonatomic, getter = isCrashManagerDisabled) BOOL disableCrashManager;

/**
 Flag the determines whether the Metrics Manager should be disabled
 
 If this flag is enabled, then metrics collection is disabled and metrics data will
 not be collected and send.
 
 *Default*: _NO_
 @see metricsManager
 */
@property (nonatomic, getter = isMetricsManagerDisabled) BOOL disableMetricsManager;


///-----------------------------------------------------------------------------
/// @name Environment
///-----------------------------------------------------------------------------

/**
 Flag that determines whether the application is installed and running
 from an App Store installation.
 
 Returns _YES_ if the app is installed and running from the App Store
 Returns _NO_ if the app is installed via debug, ad-hoc or enterprise distribution
 */
@property (nonatomic, readonly, getter=isAppStoreEnvironment) BOOL appStoreEnvironment;


/**
 Returns the app installation specific anonymous UUID
 
 The value returned by this method is unique and persisted per app installation
 in the keychain.  It is also being used in crash reports as `CrashReporter Key`
 and internally when sending crash reports and feedback messages.
 
 This is not identical to the `[ASIdentifierManager advertisingIdentifier]` or
 the `[UIDevice identifierForVendor]`!
 */
@property (nonatomic, readonly) NSString *installString;


///-----------------------------------------------------------------------------
/// @name Debug Logging
///-----------------------------------------------------------------------------

/**
 Flag that determines whether additional logging output should be generated
 by the manager and all modules.
 
 This is ignored if the app is running in the App Store and reverts to the
 default value in that case.
 
 @warning This property needs to be set before calling `startManager`
 
 *Default*: _NO_
 */
@property (nonatomic, assign, getter=isDebugLogEnabled) BOOL debugLogEnabled;


///-----------------------------------------------------------------------------
/// @name Integration test
///-----------------------------------------------------------------------------

/**
 Pings the server with the AppInsights app identifiers used for initialization
 
 Call this method once for debugging purposes to test if your SDK setup code
 reaches the server successfully.
 
 Once invoked, check the apps page on AppInsights for a verification.
 
 If you setup the SDK with a beta and live identifier, a call to both app IDs will be done.

 This call is ignored if the app is running in the App Store!.
 */
- (void)testIdentifier;


///-----------------------------------------------------------------------------
/// @name Additional meta data
///-----------------------------------------------------------------------------

/** Set the userid that should used in the SDK components
 
 Right now this is used by the `MSAICrashManager` to attach to a crash report.
 `MSAIFeedbackManager` uses it too for assigning the user to a discussion thread.

 The value can be set at any time and will be stored in the keychain on the current
 device only! To delete the value from the keychain set the value to `nil`.
 
 This property is optional and can be used as an alternative to the delegate. If you
 want to define specific data for each component, use the delegate instead which does
 overwrite the values set by this property.
 
 @warning When returning a non nil value, crash reports are not anonymous any more
 and the crash alerts will not show the word "anonymous"!
 
 @warning This property needs to be set before calling `startManager` to be considered
 for being added to crash reports as meta data.

 @see userName
 @see userEmail
 @see `[MSAITelemetryManagerDelegate userIDForManager:componentManager:]`
 */
@property (nonatomic, retain) NSString *userID;


/** Set the user name that should used in the SDK components
 
 Right now this is used by the `MSAICrashManager` to attach to a crash report.
 `MSAIFeedbackManager` uses it too for assigning the user to a discussion thread.
 
 The value can be set at any time and will be stored in the keychain on the current
 device only! To delete the value from the keychain set the value to `nil`.
 
 This property is optional and can be used as an alternative to the delegate. If you
 want to define specific data for each component, use the delegate instead which does
 overwrite the values set by this property.

 @warning When returning a non nil value, crash reports are not anonymous any more
 and the crash alerts will not show the word "anonymous"!

 @warning This property needs to be set before calling `startManager` to be considered
 for being added to crash reports as meta data.

 @see userID
 @see userEmail
 @see `[MSAITelemetryManagerDelegate userNameForManager:componentManager:]`
 */
@property (nonatomic, retain) NSString *userName;


/** Set the users email address that should used in the SDK components
 
 Right now this is used by the `MSAICrashManager` to attach to a crash report.
 `MSAIFeedbackManager` uses it too for assigning the user to a discussion thread.
 
 The value can be set at any time and will be stored in the keychain on the current
 device only! To delete the value from the keychain set the value to `nil`.
 
 This property is optional and can be used as an alternative to the delegate. If you
 want to define specific data for each component, use the delegate instead which does
 overwrite the values set by this property.
 
 @warning When returning a non nil value, crash reports are not anonymous any more
 and the crash alerts will not show the word "anonymous"!
 
 @warning This property needs to be set before calling `startManager` to be considered
 for being added to crash reports as meta data.

 @see userID
 @see userName
 @see `[MSAITelemetryManagerDelegate userEmailForManager:componentManager:]`
 */
@property (nonatomic, retain) NSString *userEmail;


///-----------------------------------------------------------------------------
/// @name SDK meta data
///-----------------------------------------------------------------------------

/**
 Returns the SDK Version (CFBundleShortVersionString).
 */
- (NSString *)version;

/**
 Returns the SDK Build (CFBundleVersion) as a string.
 */
- (NSString *)build;

@end
