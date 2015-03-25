#import "AppInsights.h"

#if MSAI_FEATURE_CRASH_REPORTER

#import "AppInsightsPrivate.h"
#import "MSAIHelper.h"
#import "MSAICrashManagerPrivate.h"
#import "MSAICrashDataProvider.h"
#import "MSAICrashDetailsPrivate.h"
#import "MSAICrashData.h"
#import "MSAIChannel.h"
#import "MSAIChannelPrivate.h"
#import "MSAIPersistence.h"
#import "MSAIEnvelope.h"
#import "MSAIEnvelopeManager.h"
#import "MSAIEnvelopeManagerPrivate.h"
#import "MSAIData.h"
#import <mach-o/loader.h>
#import <mach-o/dyld.h>

#include <sys/sysctl.h>
// stores the set of crashreports that have been approved but aren't sent yet
#define kMSAICrashApprovedReports @"MSAICrashApprovedReports" //TODO remove this in next Sprint

// internal keys
NSString *const kMSAICrashManagerIsDisabled = @"MSAICrashManagerIsDisabled";

NSString *const kMSAIAppWentIntoBackgroundSafely = @"MSAIAppWentIntoBackgroundSafely";
NSString *const kMSAIAppDidReceiveLowMemoryNotification = @"MSAIAppDidReceiveLowMemoryNotification";

static MSAICrashManagerCallbacks msaiCrashCallbacks = {
    .context = NULL,
    .handleSignal = NULL
};

// proxy implementation for PLCrashReporter to keep our interface stable while this can change
static void plcr_post_crash_callback(siginfo_t *info, ucontext_t *uap, void *context) {
  if(msaiCrashCallbacks.handleSignal != NULL)
    msaiCrashCallbacks.handleSignal(context);
}

static PLCrashReporterCallbacks plCrashCallbacks = {
    .version = 0,
    .context = NULL,
    .handleSignal = plcr_post_crash_callback
};

@implementation MSAICrashManager {
  id _appDidBecomeActiveObserver;
  id _appWillTerminateObserver;
  id _appDidEnterBackgroundObserver;
  id _appWillEnterForegroundObserver;
  id _appDidReceiveLowMemoryWarningObserver;
}

#pragma mark - Start

+ (instancetype)sharedManager {
  static MSAICrashManager *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [self new];
  });
  return sharedManager;
}

/**
*	 Main startup sequence initializing PLCrashReporter if it wasn't disabled
*/
- (void)startManager {
  if(self.isCrashManagerDisabled) return;
  if(![MSAICrashManager sharedManager].isSetupCorrectly) {
    [self checkCrashManagerDisabled];

    [self registerObservers];

    static dispatch_once_t plcrPredicate;
    dispatch_once(&plcrPredicate, ^{
      _timeintervalCrashInLastSessionOccured = -1;

      [[MSAIPersistence sharedInstance] deleteCrashReporterLockFile];

      [self configPLCrashReporter];

      // Check if we previously crashed
      if([self.plCrashReporter hasPendingCrashReport]) {
        _didCrashInLastSession = YES;
        [self readCrashReportAndStartProcessing];
      }

      // The actual signal and mach handlers are only registered when invoking `enableCrashReporterAndReturnError`
      // So it is safe enough to only disable the following part when a debugger is attached no matter which
      // signal handler type is set
      // We only check for this if we are not in the App Store environment

      if(!msai_isAppStoreEnvironment()) {
        if(self.debuggerIsAttached) {
          NSLog(@"[AppInsights] WARNING: Detecting crashes is NOT enabled due to running the app with a debugger attached.");
        }
      }

      [self setupExceptionHandler];
    });

    [self checkForLowMemoryWarning];
    [self checkStateOfLastSession];
    [self appEnteredForeground];

    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kMSAIAppDidReceiveLowMemoryNotification];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [MSAICrashManager sharedManager].isSetupCorrectly = YES;
  }
}

- (void)dealloc {
  [self unregisterObservers];
}

#pragma mark - Start Helpers

- (void)checkStateOfLastSession {
  if(!self.didCrashInLastSession && self.appNotTerminatingCleanlyDetectionEnabled) {
    BOOL didAppSwitchToBackgroundSafely = YES;

    if([[NSUserDefaults standardUserDefaults] valueForKey:kMSAIAppWentIntoBackgroundSafely])
      didAppSwitchToBackgroundSafely = [[NSUserDefaults standardUserDefaults] boolForKey:kMSAIAppWentIntoBackgroundSafely];

    if(!didAppSwitchToBackgroundSafely) {
      BOOL considerReport = YES;

      if(self.delegate &&
          [self.delegate respondsToSelector:@selector(considerAppNotTerminatedCleanlyReportForCrashManager)]) {
        considerReport = [self.delegate considerAppNotTerminatedCleanlyReportForCrashManager];
      }

      if(considerReport) {
        [self createCrashReportForAppKill];

        _didCrashInLastSession = YES;
      }
    }
  }
}

- (void)checkForLowMemoryWarning {
  if([[NSUserDefaults standardUserDefaults] valueForKey:kMSAIAppDidReceiveLowMemoryNotification]) {
    _didReceiveMemoryWarningInLastSession = [[NSUserDefaults standardUserDefaults] boolForKey:kMSAIAppDidReceiveLowMemoryNotification];
  }
}

- (void)setupExceptionHandler {
  if(!self.debuggerIsAttached) {
    // Multiple exception handlers can be set, but we can only query the top level error handler (uncaught exception handler).
    //
    // To check if PLCrashReporter's error handler is successfully added, we compare the top
    // level one that is set before and the one after PLCrashReporter sets up its own.
    //
    // With delayed processing we can then check if another error handler was set up afterwards
    // and can show a debug warning log message, that the dev has to make sure the "newer" error handler
    // doesn't exit the process itself, because then all subsequent handlers would never be invoked.
    //
    // Note: ANY error handler setup BEFORE AppInsights initialization will not be processed!

    // get the current top level error handler
    NSUncaughtExceptionHandler *initialHandler = NSGetUncaughtExceptionHandler();

    // PLCrashReporter may only be initialized once. So make sure the developer
    // can't break this
    NSError *error = NULL;

    // set any user defined callbacks, hopefully the users knows what they do
    if(self.crashCallBacks) {
      [self.plCrashReporter setCrashCallbacks:self.crashCallBacks];
    }

    // Enable the Crash Reporter
    if(![self.plCrashReporter enableCrashReporterAndReturnError:&error]) {
      NSLog(@"[AppInsights] WARNING: Could not enable crash reporter: %@", [error localizedDescription]);
    }

    // get the new current top level error handler, which should now be the one from PLCrashReporter
    NSUncaughtExceptionHandler *currentHandler = NSGetUncaughtExceptionHandler();

    // do we have a new top level error handler? then we were successful
    if(currentHandler && currentHandler != initialHandler) {
      self.exceptionHandler = currentHandler;

      MSAILog(@"INFO: Exception handler successfully initialized.");
    } else {
      // this should never happen, theoretically only if NSSetUncaugtExceptionHandler() has some internal issues
      NSLog(@"[AppInsights] ERROR: Exception handler could not be set. Make sure there is no other exception handler set up!");
    }
  }
}

- (void)configPLCrashReporter {
  PLCrashReporterSignalHandlerType signalHandlerType = PLCrashReporterSignalHandlerTypeBSD;
  if(self.machExceptionHandlerEnabled) {
    signalHandlerType = PLCrashReporterSignalHandlerTypeMach;
  }

  PLCrashReporterSymbolicationStrategy symbolicationStrategy = PLCrashReporterSymbolicationStrategyNone;
  if(self.onDeviceSymbolicationEnabled) {
    symbolicationStrategy = PLCrashReporterSymbolicationStrategyAll;
  }

  MSAIPLCrashReporterConfig *config = [[MSAIPLCrashReporterConfig alloc] initWithSignalHandlerType:signalHandlerType
                                                                             symbolicationStrategy:symbolicationStrategy];
  self.plCrashReporter = [[MSAIPLCrashReporter alloc] initWithConfiguration:config];
}

- (void)checkCrashManagerDisabled {
  NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:kMSAICrashManagerIsDisabled];
  if(testValue) {
    self.isCrashManagerDisabled = [[NSUserDefaults standardUserDefaults] boolForKey:kMSAICrashManagerIsDisabled];
  } else {
    [[NSUserDefaults standardUserDefaults] setBool:self.isCrashManagerDisabled forKey:kMSAICrashManagerIsDisabled];
  }
}

#pragma mark - Configuration

// Enable/Disable the CrashManager and store the setting in standardUserDefaults
- (void)setCrashManagerDisabled:(BOOL)disableCrashManager {
  _isCrashManagerDisabled = disableCrashManager;
  [[NSUserDefaults standardUserDefaults] setBool:disableCrashManager forKey:kMSAICrashManagerIsDisabled];
}

/**
*  Set the callback for PLCrashReporter
*
*  @param callbacks MSAICrashManagerCallbacks instance
*/
- (void)setCrashCallbacks:(MSAICrashManagerCallbacks *)callbacks {
  if(!callbacks) return;

  // set our proxy callback struct
  msaiCrashCallbacks.context = callbacks->context;
  msaiCrashCallbacks.handleSignal = callbacks->handleSignal;

  // set the PLCrashReporterCallbacks struct
  plCrashCallbacks.context = callbacks->context;

  self.crashCallBacks = &plCrashCallbacks;
}

#pragma mark - Debugging Helpers

/**
* Check if the debugger is attached
*
* Taken from https://github.com/plausiblelabs/plcrashreporter/blob/2dd862ce049e6f43feb355308dfc710f3af54c4d/Source/Crash%20Demo/main.m#L96
*
* @return `YES` if the debugger is attached to the current process, `NO` otherwise
*/
- (BOOL)getIsDebuggerAttached {
  static BOOL debuggerIsAttached = NO;

  static dispatch_once_t debuggerPredicate;
  dispatch_once(&debuggerPredicate, ^{
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    int name[4];

    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();

    if(sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
      NSLog(@"[AppInsights] ERROR: Checking for a running debugger via sysctl() failed: %s", strerror(errno));
      debuggerIsAttached = false;
    }

    if(!debuggerIsAttached && (info.kp_proc.p_flag & P_TRACED) != 0)
      debuggerIsAttached = true;
  });

  return debuggerIsAttached;
}

- (void)generateTestCrash {
  if(!msai_isAppStoreEnvironment()) {

    if(self.debuggerIsAttached) {
      NSLog(@"[AppInsights] WARNING: The debugger is attached. The following crash cannot be detected by the SDK!");
    }

    __builtin_trap();
  }
}

#pragma mark - Lifecycle Notifications

- (void)registerObservers {
  __weak typeof(self) weakSelf = self;

  if(nil == _appDidBecomeActiveObserver) {
    _appDidBecomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                                    object:nil
                                                                                     queue:NSOperationQueue.mainQueue
                                                                                usingBlock:^(NSNotification *note) {
                                                                                  typeof(self) strongSelf = weakSelf;
                                                                                  [strongSelf readCrashReportAndStartProcessing];
                                                                                }];
  }

  if(nil == _appWillTerminateObserver) {
    _appWillTerminateObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification
                                                                                  object:nil
                                                                                   queue:NSOperationQueue.mainQueue
                                                                              usingBlock:^(NSNotification *note) {
                                                                                typeof(self) strongSelf = weakSelf;
                                                                                [strongSelf leavingAppSafely];
                                                                              }];
  }

  if(nil == _appDidEnterBackgroundObserver) {
    _appDidEnterBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                                                       object:nil
                                                                                        queue:NSOperationQueue.mainQueue
                                                                                   usingBlock:^(NSNotification *note) {
                                                                                     typeof(self) strongSelf = weakSelf;
                                                                                     [strongSelf leavingAppSafely];
                                                                                   }];
  }

  if(nil == _appWillEnterForegroundObserver) {
    _appWillEnterForegroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                                                        object:nil
                                                                                         queue:NSOperationQueue.mainQueue
                                                                                    usingBlock:^(NSNotification *note) {
                                                                                      typeof(self) strongSelf = weakSelf;
                                                                                      [strongSelf appEnteredForeground];
                                                                                    }];
  }

  if(nil == _appDidReceiveLowMemoryWarningObserver) {
    _appDidReceiveLowMemoryWarningObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                                                               object:nil
                                                                                                queue:NSOperationQueue.mainQueue
                                                                                           usingBlock:^(NSNotification *note) {
                                                                                             typeof(self) strongSelf = weakSelf;
                                                                                             // we only need to log this once
                                                                                             if(!strongSelf.didLogLowMemoryWarning) {
                                                                                               [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMSAIAppDidReceiveLowMemoryNotification];
                                                                                               [[NSUserDefaults standardUserDefaults] synchronize];
                                                                                               strongSelf.didLogLowMemoryWarning = YES;
                                                                                             }
                                                                                           }];
  }
}

- (void)unregisterObservers {
  [self unregisterObserver:_appDidBecomeActiveObserver];
  [self unregisterObserver:_appWillTerminateObserver];
  [self unregisterObserver:_appDidEnterBackgroundObserver];
  [self unregisterObserver:_appWillEnterForegroundObserver];

  [self unregisterObserver:_appDidReceiveLowMemoryWarningObserver];
}

- (void)unregisterObserver:(id)observer {
  if(observer) {
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
    observer = nil;
  }
}

//Safe info about safe termination of the app to NSUserDefaults
- (void)leavingAppSafely {
  if(self.appNotTerminatingCleanlyDetectionEnabled)
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMSAIAppWentIntoBackgroundSafely];
}

/**
* Stores info about didEnterBackground in NSUserDefaults.
*/

- (void)appEnteredForeground {
  // we disable kill detection while the debugger is running, since we'd get only false positives if the app is terminated by the user using the debugger
  if(self.debuggerIsAttached) {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMSAIAppWentIntoBackgroundSafely];
  } else if(self.appNotTerminatingCleanlyDetectionEnabled) {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kMSAIAppWentIntoBackgroundSafely];
  }
}


#pragma mark - PLCrashReporter

/**
*	 Process new crash reports provided by PLCrashReporter
*
* Parse the new crash report and gather additional meta data from the app which will be stored along the crash report
*/
- (void)readCrashReportAndStartProcessing {
  NSError *error = NULL;

  if(!self.plCrashReporter) {
    return;
  }

  NSData *crashData;

  // check if the next call ran successfully the last time
  // check again if we have a pending crash report to be sure we actually have something to load
  if(![[MSAIPersistence sharedInstance] crashReportLockFilePresent] && [self.plCrashReporter hasPendingCrashReport]) {
    // mark the start of the routine
    [[MSAIPersistence sharedInstance] createCrashReporterLockFile];

    // Try loading the crash report
    crashData = [[NSData alloc] initWithData:[self.plCrashReporter loadPendingCrashReportDataAndReturnError:&error]];

    if(crashData == nil) {
      MSAILog(@"ERROR: Could not load crash report: %@", error);
    } else {
      // get the startup timestamp from the crash report, and the file timestamp to calculate the timeinterval when the crash happened after startup
      MSAIPLCrashReport *report = [[MSAIPLCrashReport alloc] initWithData:crashData error:&error];

      if(report == nil) {
        MSAILog(@"WARNING: Could not parse crash report");
      }
      else {
        NSDate *appStartTime = nil;
        NSDate *appCrashTime = nil;
        if([report.processInfo respondsToSelector:@selector(processStartTime)]) {
          if(report.systemInfo.timestamp && report.processInfo.processStartTime) {
            appStartTime = report.processInfo.processStartTime;
            appCrashTime = report.systemInfo.timestamp;
            _timeintervalCrashInLastSessionOccured = [report.systemInfo.timestamp timeIntervalSinceDate:report.processInfo.processStartTime];
          }
        }

        NSString *incidentIdentifier = @"???";
        if(report.uuidRef != NULL) {
          incidentIdentifier = (NSString *) CFBridgingRelease(CFUUIDCreateString(NULL, report.uuidRef));
        }

        NSString *reporterKey = msai_appAnonID() ?: @"";

        _lastSessionCrashDetails = [[MSAICrashDetails alloc] initWithIncidentIdentifier:incidentIdentifier
                                                                            reporterKey:reporterKey
                                                                                 signal:report.signalInfo.name
                                                                          exceptionName:report.exceptionInfo.exceptionName
                                                                        exceptionReason:report.exceptionInfo.exceptionReason
                                                                           appStartTime:appStartTime
                                                                              crashTime:appCrashTime
                                                                              osVersion:report.systemInfo.operatingSystemVersion
                                                                                osBuild:report.systemInfo.operatingSystemBuild
                                                                               appBuild:report.applicationInfo.applicationVersion
        ];
      }
    }
  }

  if(!msai_isRunningInAppExtension() &&
      [[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
    return;
  }

  // check again if another exception handler was added with a short delay
  [self performSelector:@selector(checkForOtherExceptionHandlersAfterSetup) withObject:nil afterDelay:0.5f];

  [self createCrashReportWithCrashData:crashData];

  // Purge the report
  // mark the end of the routine
  [[MSAIPersistence sharedInstance] deleteCrashReporterLockFile];//TODO only do this when persisting was successful?
  [self.plCrashReporter purgePendingCrashReport]; //TODO only do this when persisting was successful?
}

- (void)checkForOtherExceptionHandlersAfterSetup {
  // was our own exception handler successfully added?
  if (self.exceptionHandler) {
    // get the current top level error handler
    NSUncaughtExceptionHandler *currentHandler = NSGetUncaughtExceptionHandler();

    // If the top level error handler differs from our own, then at least another one was added.
    // This could cause exception crashes not to be reported to HockeyApp. See log message for details.
    if (self.exceptionHandler != currentHandler) {
      NSLog(@"[AppInsights] ERROR: Exception handler could not be set. Make sure there is no other exception handler set up!");
    }
  }
}

#pragma mark - Crash Report Processing

/**
*  Creates a crash template because the app was killed while being in foreground
*/
- (void)createCrashReportForAppKill {
  MSAICrashDataHeaders *crashHeaders = [MSAICrashDataHeaders new];
  crashHeaders.crashDataHeadersId = msai_UUID();
  crashHeaders.exceptionType = kMSAICrashKillSignal;
  crashHeaders.exceptionCode = @"00000020 at 0x8badf00d";
  crashHeaders.exceptionReason = @"The application did not terminate cleanly but no crash occured. The app received at least one Low Memory Warning.";

  MSAICrashData *crashData = [MSAICrashData new];
  crashData.headers = crashHeaders;

  MSAIData *data = [MSAIData new];
  data.baseData = crashData;
  data.baseType = crashData.dataTypeName;

  MSAIEnvelope *crashTemplate = [[MSAIEnvelopeManager sharedManager] envelope];
  crashTemplate.data = data;
  crashTemplate.name = crashData.envelopeTypeName;

  [[MSAIPersistence sharedInstance] persistCrashTemplateBundle:@[crashTemplate]];
}

/***
* Gathers all collected data and constructs Crash into an Envelope for processing
*/
- (void)createCrashReportWithCrashData:(NSData*)crashData {
  if(!crashData) {
    return;
  }

  NSError *error = NULL;

  if([crashData length] > 0) {
    MSAIPLCrashReport *report = nil;
    MSAIEnvelope *crashEnvelope = nil;

    report = [[MSAIPLCrashReport alloc] initWithData:crashData error:&error];

    if(report) {
      crashEnvelope = [MSAICrashDataProvider crashDataForCrashReport:report];
      if([report.applicationInfo.applicationVersion compare:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]] == NSOrderedSame) {
        //TODO Check if this has to be added again
//        _crashIdenticalCurrentVersion = YES;
      }
    }

    if([report.applicationInfo.applicationVersion compare:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]] == NSOrderedSame) {
      //TODO Check if this has to be added again
//        _crashIdenticalCurrentVersion = YES;
    }

    if(report == nil && crashEnvelope == nil) {
      MSAILog(@"WARNING: Could not parse crash report");
      // we cannot do anything with this report, so don't continue
      // the next crash will be automatically processed on the next app start/becoming active event
      return;
    }

    MSAILog(@"INFO: Persisting crash reports started.");
    [[MSAIChannel sharedChannel] processDictionary:[crashEnvelope serializeToDictionary] withCompletionBlock:nil];
  }
}

#pragma mark - Logging Helpers

- (void)reportError:(NSError *)error {
  MSAILog(@"ERROR: %@", [error localizedDescription]);
}

@end

#endif /* MSAI_FEATURE_CRASH_REPORTER */

