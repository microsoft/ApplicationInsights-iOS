#import <Foundation/Foundation.h>

@class MSAICrashDetails;
@class MSAICrashMetaData;
@class MSAIContext;

/**
* Prototype of a callback function used to execute additional user code. Called upon completion of crash
* handling, after the crash report has been written to disk.
*
* @param context The API client's supplied context value.
*
* @see `MSAICrashManagerCallbacks`
* @see `[MSAICrashManager setCrashCallbacks:]`
*/
typedef void (*MSAICrashManagerPostCrashSignalCallback)(void *context);

/**
* This structure contains callbacks supported by `MSAICrashManager` to allow the host application to perform
* additional tasks prior to program termination after a crash has occured.
*
* @see `MSAICrashManagerPostCrashSignalCallback`
* @see `[MSAICrashManager setCrashCallbacks:]`
*/
typedef struct MSAICrashManagerCallbacks {
  /** An arbitrary user-supplied context value. This value may be NULL. */
  void *context;

  /**
  * The callback used to report caught signal information.
  */
  MSAICrashManagerPostCrashSignalCallback handleSignal;
} MSAICrashManagerCallbacks;

@protocol MSAICrashManagerDelegate;

/**
The crash reporting module.

This is the AppInsights module for handling crash reports, including when distributed via the App Store.
As a foundation it is using the open source, reliable and async-safe crash reporting framework
[PLCrashReporter](https://code.google.com/p/plcrashreporter/).

This module works as a wrapper around the underlying crash reporting framework and provides functionality to
detect new crashes.

It also provides options via `MSAICrashManagerDelegate` protocol and a way to detect startup crashes so you
can adjust your startup process to get these crash reports too and delay your app initialization.

Crashes are send the next time the app starts. This module is not sending the reports right when the crash happens
deliberately, because if is not safe to implement such a mechanism while being async-safe (any Objective-C code
is _NOT_ async-safe!) and not causing more danger like a deadlock of the device, than helping. We found that users
do start the app again because most don't know what happened, and you will get by far most of the reports.

Sending the reports on startup is done asynchronously (non-blocking). This is the only safe way to ensure
that the app won't be possibly killed by the iOS watchdog process, because startup could take too long
and the app could not react to any user input when network conditions are bad or connectivity might be
very slow.

It is possible to check upon startup if the app crashed before using `didCrashInLastSession` and also how much
time passed between the app launch and the crash using `timeintervalCrashInLastSessionOccured`. This allows you
to add additional code to your app delaying the app start until the crash has been successfully send if the crash
occured within a critical startup timeframe, e.g. after 10 seconds. The `MSAICrashManagerDelegate` protocol provides
various delegates to inform the app about it's current status so you can continue the remaining app startup setup
after sending has been completed. The documentation contains a guide
[How to handle Crashes on startup](HowTo-Handle-Crashes-On-Startup) with an example on how to do that.

More background information on this topic can be found in the following blog post by Landon Fuller, the
developer of [PLCrashReporter](https://www.plcrashreporter.org), about writing reliable and
safe crash reporting: [Reliable Crash Reporting](http://goo.gl/WvTBR)

@warning If you start the app with the Xcode debugger attached, detecting crashes will _NOT_ be enabled!
*/

@interface MSAICrashManager : NSObject

///-----------------------------------------------------------------------------
/// @name Initialization
///-----------------------------------------------------------------------------

+ (instancetype)sharedManager;

/**
* Indicates if the MSAICrashManager is initialised correctly.*
*/
@property (nonatomic, assign) BOOL isSetupCorrectly;

///-----------------------------------------------------------------------------
/// @name Configuration
///-----------------------------------------------------------------------------

/**
* Indicates if the CrashManager has been disabled.
* The CrashManager is enabled by default.
* Set this after initialization (you can check the `isSetupCorrectly´property to find out) to disable the CrashManager.
* Usually, this isn't done directly on MSAICrashManger but the interface provided by `MSAIAppInsights´
* @default: NO
* @see MSAIAppInsights
*/
@property (nonatomic, assign, setter=setCrashManagerDisabled:) BOOL isCrashManagerDisabled;

//TODO move the properties to the private header to make sure developers don't use the MSAICrashmanager but MSAIAppInsights

/**
*  Trap fatal signals via a Mach exception server.
*
*  By default the SDK is using the safe and proven in-process BSD Signals for catching crashes.
*  This option provides an option to enable catching fatal signals via a Mach exception server
*  instead.
*
*  We strongly advice _NOT_ to enable Mach exception handler in release versions of your apps!
*
*  Default: _NO_
*
* @warning The Mach exception handler executes in-process, and will interfere with debuggers when
*  they attempt to suspend all active threads (which will include the Mach exception handler).
*  Mach-based handling should _NOT_ be used when a debugger is attached. The SDK will not
*  enabled catching exceptions if the app is started with the debugger running. If you attach
*  the debugger during runtime, this may cause issues the Mach exception handler is enabled!
* @see debuggerIsAttached
*/

@property (nonatomic, assign) BOOL machExceptionHandlerEnabled;

/**
*  Enable on device symbolication for system symbols
*
*  By default, the SDK does not symbolicate on the device, since this can
*  take a few seconds at each crash. Also note that symbolication on the
*  device might not be able to retrieve all symbols.
*
*  Enable if you want to analyze crashes on unreleased OS versions.
*
*  Default: _NO_
*/
@property (nonatomic, assign) BOOL onDeviceSymbolicationEnabled;


/**
*  EXPERIMENTAL: Enable heuristics to detect the app not terminating cleanly
*
*  This allows it to get a crash report if the app got killed while being in the foreground
*  because of now of the following reasons:
*  - The main thread was blocked for too long
*  - The app took too long to start up
*  - The app tried to allocate too much memory. If iOS did send a memory warning before killing the app because of this reason, `didReceiveMemoryWarningInLastSession` returns `YES`.
*  - Permitted background duration if main thread is running in an endless loop
*  - App failed to resume in time if main thread is running in an endless loop
*  - If `enableMachExceptionHandler` is not activated, crashed due to stackoverflow will also be reported
*
*  The following kills can _NOT_ be detected:
*  - Terminating the app takes too long
*  - Permitted background duration too long for all other cases
*  - App failed to resume in time for all other cases
*  - possibly more cases
*
*  Crash reports triggered by this mechanisms do _NOT_ contain any stack traces since the time of the kill
*  cannot be intercepted and hence no stack trace of the time of the kill event can't be gathered.
*
*  The heuristic is implemented as follows:
*  If the app never gets a `UIApplicationDidEnterBackgroundNotification` or `UIApplicationWillTerminateNotification`
*  notification, PLCrashReporter doesn't detect a crash itself, and the app starts up again, it is assumed that
*  the app got either killed by iOS while being in foreground or a crash occured that couldn't be detected.
*
*  Default: _NO_
*
* @warning This is a heuristic and it _MAY_ report false positives! It has been tested with iOS 6.1 and iOS 7.
* Depending on Apple changing notification events, new iOS version may cause more false positives!
*
* @see lastSessionCrashDetails
* @see didReceiveMemoryWarningInLastSession
* @see `MSAICrashManagerDelegate considerAppNotTerminatedCleanlyReportForCrashManager:`
* @see [Apple Technical Note TN2151](https://developer.apple.com/library/ios/technotes/tn2151/_index.html)
* @see [Apple Technical Q&A QA1693](https://developer.apple.com/library/ios/qa/qa1693/_index.html)
*/
@property (nonatomic, assign) BOOL appNotTerminatingCleanlyDetectionEnabled;

/**
* Set the callbacks that will be executed prior to program termination after a crash has occurred
*
* PLCrashReporter provides support for executing an application specified function in the context
* of the crash reporter's signal handler, after the crash report has been written to disk.
*
* Writing code intended for execution inside of a signal handler is exceptionally difficult, and is _NOT_ recommended!
*
* _Program Flow and Signal Handlers_
*
* When the signal handler is called the normal flow of the program is interrupted, and your program is an unknown state. Locks may be held, the heap may be corrupt (or in the process of being updated), and your signal handler may invoke a function that was being executed at the time of the signal. This may result in deadlocks, data corruption, and program termination.
*
* _Async-Safe Functions_
*
* A subset of functions are defined to be async-safe by the OS, and are safely callable from within a signal handler. If you do implement a custom post-crash handler, it must be async-safe. A table of POSIX-defined async-safe functions and additional information is available from the [CERT programming guide - SIG30-C](https://www.securecoding.cert.org/confluence/display/seccode/SIG30-C.+Call+only+asynchronous-safe+functions+within+signal+handlers).
*
* Most notably, the Objective-C runtime itself is not async-safe, and Objective-C may not be used within a signal handler.
*
* Documentation taken from PLCrashReporter: https://www.plcrashreporter.org/documentation/api/v1.2-rc2/async_safety.html
*
* @see MSAICrashManagerPostCrashSignalCallback
* @see MSAICrashManagerCallbacks
*
* @param callbacks A pointer to an initialized PLCrashReporterCallback structure, see https://www.plcrashreporter.org/documentation/api/v1.2-rc2/struct_p_l_crash_reporter_callbacks.html
*/
- (void)setCrashCallbacks:(MSAICrashManagerCallbacks *)callbacks;


///-----------------------------------------------------------------------------
/// @name Crash Meta Information
///-----------------------------------------------------------------------------

/**
Indicates if the app crash in the previous session

Use this on startup, to check if the app starts the first time after it crashed
previously. You can use this also to disable specific events, like asking
the user to rate your app.

@warning This property only has a correct value, once `[MSAIAppInsights start]` was
invoked!

@see lastSessionCrashDetails
*/

@property (nonatomic, readonly) BOOL didCrashInLastSession;

/**
* Provides details about the crash that occured in the last app session
*/
@property (nonatomic, strong, readonly) MSAICrashDetails *lastSessionCrashDetails;

/**
Provides the time between startup and crash in seconds

Use this in together with `didCrashInLastSession` to detect if the app crashed very
early after startup. This can be used to delay app initialization until the crash
report has been sent to the server or if you want to do any other actions like
cleaning up some cache data etc.

Note that sending a crash reports starts as early as 1.5 seconds after the application
did finish launching!

The `MSAICrashManagerDelegate` protocol provides some delegates to inform if sending
a crash report was finished successfully, ended in error or was cancelled by the user.

*Default*: _-1_
@see didCrashInLastSession
@see MSAICrashManagerDelegate
*/
@property (nonatomic, readonly) NSTimeInterval timeintervalCrashInLastSessionOccured;


/**
Indicates if the app did receive a low memory warning in the last session

It may happen that low memory warning where send but couldn't be logged, since iOS
killed the app before updating the flag in the filesystem did complete.

This property may be true in case of low memory kills, but it doesn't have to be! Apps
can also be killed without the app ever receiving a low memory warning.

Also the app could have received a low memory warning, but the reason for being killed was
actually different.

@warning This property only has a correct value, once `[MSAIAppInsights start]` was
invoked!

@see appNotTerminatingCleanlyDetectionEnabled
@see lastSessionCrashDetails
*/

@property (nonatomic, readonly) BOOL didReceiveMemoryWarningInLastSession;

///-----------------------------------------------------------------------------
/// @name Debugging Helpers
///-----------------------------------------------------------------------------

/**
*  Detect if a debugger is attached to the app process
*
*  This is only invoked once on app startup and can not detect if the debugger is being
*  attached during runtime!
*
*  @return BOOL if the debugger is attached on app startup
*/

@property (nonatomic, readonly, getter=getIsDebuggerAttached) BOOL debuggerIsAttached;

/**
* Lets the app crash for easy testing of the SDK
*
* The best way to use this is to trigger the crash with a button action.
*
* Make sure not to let the app crash in `applicationDidFinishLaunching` or any other
* startup method! Since otherwise the app would crash before the SDK could process it.
*
* Note that our SDK provides support for handling crashes that happen early on startup.
* Check the documentation for more information on how to use this.
*
* If the SDK detects an App Store environment, it will _NOT_ cause the app to crash!
*/
- (void)generateTestCrash;

@end
