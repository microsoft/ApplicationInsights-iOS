#import "AppInsights.h"

#if MSAI_FEATURE_CRASH_REPORTER

#import "AppInsightsPrivate.h"
#import "MSAIHelper.h"
#import "MSAIContextPrivate.h"
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

//TODO: don't use a static
static MSAICrashManagerCallbacks msaiCrashCallbacks = {
    .context = NULL,
    .handleSignal = NULL
};

// proxy implementation for PLCrashReporter to keep our interface stable while this can change
static void plcr_post_crash_callback(siginfo_t *info, ucontext_t *uap, void *context) {
  if(msaiCrashCallbacks.handleSignal != NULL)
    msaiCrashCallbacks.handleSignal(context);
}

//TODO: don't use static
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
  id _networkDidBecomeReachableObserver;
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

+ (void)startWithContext:(MSAIContext *)context {
  //TODO does it make sense to have everything not initialised if the context is nil?
  if(context) {
    if(![MSAICrashManager sharedManager].isSetupCorrectly) {
      [[self sharedManager] startManager];
    }
  }
}

/**
*	 Main startup sequence initializing PLCrashReporter if it wasn't disabled
*/
- (void)startManager {
  if(self.isCrashManagerDisabled) return;
  static dispatch_once_t plcrPredicate;
  dispatch_once(&plcrPredicate, ^{
    [self initValues];

    [self registerObservers];
    [self loadSettings];

    /* Configure our reporter */

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

    // Check if we previously crashed
    if([self.plCrashReporter hasPendingCrashReport]) {
      _didCrashInLastSession = YES;
      [self handleCrashReport];
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
      if(![self.plCrashReporter enableCrashReporterAndReturnError:&error])
        NSLog(@"[AppInsights] WARNING: Could not enable crash reporter: %@", [error localizedDescription]);

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
  });

  if([[NSUserDefaults standardUserDefaults] valueForKey:kMSAIAppDidReceiveLowMemoryNotification])
    _didReceiveMemoryWarningInLastSession = [[NSUserDefaults standardUserDefaults] boolForKey:kMSAIAppDidReceiveLowMemoryNotification];

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
  [self appEnteredForeground];
  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kMSAIAppDidReceiveLowMemoryNotification];
  [[NSUserDefaults standardUserDefaults] synchronize];

  [MSAICrashManager sharedManager].isSetupCorrectly = YES;
  
  [self triggerDelayedProcessing];
}

- (void)initValues {
  _timeintervalCrashInLastSessionOccured = -1;

  self.approvedCrashReports = [[NSMutableDictionary alloc] init];

  self.fileManager = [NSFileManager new];
  self.crashFiles = [NSMutableArray new];

  NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:kMSAICrashManagerIsDisabled];
  if(testValue) {
    self.isCrashManagerDisabled = [[NSUserDefaults standardUserDefaults] boolForKey:kMSAICrashManagerIsDisabled];
  } else {
    [[NSUserDefaults standardUserDefaults] setInteger:self.isCrashManagerDisabled forKey:kMSAICrashManagerIsDisabled];
  }

  self.crashesDir = msai_settingsDir();
  self.settingsFile = [self.crashesDir stringByAppendingPathComponent:kMSAICrashSettings];
  self.analyzerInProgressFile = [self.crashesDir stringByAppendingPathComponent:kMSAICrashAnalyzer];

  if([self.fileManager fileExistsAtPath:self.analyzerInProgressFile]) {
    NSError *error = nil;
    [self.fileManager removeItemAtPath:self.analyzerInProgressFile error:&error];
  }
}

- (void)dealloc {
  [self unregisterObservers];
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

#pragma mark - (Un)register for Lifecycle Notifications

- (void)registerObservers {
  __weak typeof(self) weakSelf = self;

  if(nil == _appDidBecomeActiveObserver) {
    _appDidBecomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                                    object:nil
                                                                                     queue:NSOperationQueue.mainQueue
                                                                                usingBlock:^(NSNotification *note) {
                                                                                  typeof(self) strongSelf = weakSelf;
                                                                                  [strongSelf triggerDelayedProcessing];
                                                                                }];
  }

  if(nil == _networkDidBecomeReachableObserver) {
    _networkDidBecomeReachableObserver = [[NSNotificationCenter defaultCenter] addObserverForName:MSAINetworkDidBecomeReachableNotification
                                                                                           object:nil
                                                                                            queue:NSOperationQueue.mainQueue
                                                                                       usingBlock:^(NSNotification *note) {
                                                                                         [weakSelf triggerDelayedProcessing];
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

  [self unregisterObserver:_networkDidBecomeReachableObserver];
}

- (void)unregisterObserver:(id)observer {
  if(observer) {
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
    observer = nil;
  }
}


#pragma mark - PLCrashReporter

/**
*	 Process new crash reports provided by PLCrashReporter
*
* Parse the new crash report and gather additional meta data from the app which will be stored along the crash report
*/
- (void)handleCrashReport {
  NSError *error = NULL;

  if(!self.plCrashReporter) return;

  // check if the next call ran successfully the last time
  if(![self.fileManager fileExistsAtPath:self.analyzerInProgressFile]) {
    // mark the start of the routine
    [self.fileManager createFileAtPath:self.analyzerInProgressFile contents:nil attributes:nil];

    [self saveSettings];

    // Try loading the crash report
    NSData *crashData = [[NSData alloc] initWithData:[self.plCrashReporter loadPendingCrashReportDataAndReturnError:&error]];

    NSString *cacheFilename = [NSString stringWithFormat:@"%.0f", [NSDate timeIntervalSinceReferenceDate]];
    self.lastCrashFilename = cacheFilename;

    if(crashData == nil) {
      MSAILog(@"ERROR: Could not load crash report: %@", error);
    } else {
      // get the startup timestamp from the crash report, and the file timestamp to calculate the timeinterval when the crash happened after startup
      MSAIPLCrashReport *report = [[MSAIPLCrashReport alloc] initWithData:crashData error:&error];

      if(report == nil) {
        MSAILog(@"WARNING: Could not parse crash report");
      } else {
        NSDate *appStartTime = nil;
        NSDate *appCrashTime = nil;
        if([report.processInfo respondsToSelector:@selector(processStartTime)]) {
          if(report.systemInfo.timestamp && report.processInfo.processStartTime) {
            appStartTime = report.processInfo.processStartTime;
            appCrashTime = report.systemInfo.timestamp;
            _timeintervalCrashInLastSessionOccured = [report.systemInfo.timestamp timeIntervalSinceDate:report.processInfo.processStartTime];
          }
        }

        [crashData writeToFile:[self.crashesDir stringByAppendingPathComponent:cacheFilename] atomically:YES];

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

  // Purge the report
  // mark the end of the routine
  if([self.fileManager fileExistsAtPath:self.analyzerInProgressFile]) {
    [self.fileManager removeItemAtPath:self.analyzerInProgressFile error:&error];
  }

  [self saveSettings];

  [self.plCrashReporter purgePendingCrashReport];
}

/**
Get the filename of the first not approved crash report

@return NSString Filename of the first found not approved crash report
*/
- (NSString *)firstNotApprovedCrashReport {
  if((!self.approvedCrashReports || [self.approvedCrashReports count] == 0) && [self.crashFiles count] > 0) {
    return self.crashFiles[0];
  }

  for(NSUInteger i = 0; i < [self.crashFiles count]; i++) {
    NSString *filename = self.crashFiles[i];

    if(self.approvedCrashReports[filename]) return filename;
  }

  return nil;
}

/**
*	Check if there are any new crash reports that are not yet processed
*
*	@return	`YES` if there is at least one new crash report found, `NO` otherwise
*/
- (BOOL)hasPendingCrashReport {
  if(self.isCrashManagerDisabled) return NO;

  if([self.fileManager fileExistsAtPath:self.crashesDir]) {
    NSError *error = NULL;

    NSArray *dirArray = [self.fileManager contentsOfDirectoryAtPath:self.crashesDir error:&error];

    for(NSString *file in dirArray) {
      NSString *filePath = [self.crashesDir stringByAppendingPathComponent:file];

      NSDictionary *fileAttributes = [self.fileManager attributesOfItemAtPath:filePath error:&error];
      if([fileAttributes[NSFileType] isEqualToString:NSFileTypeRegular] &&
          [fileAttributes[NSFileSize] intValue] > 0 &&
          ![file hasSuffix:@".DS_Store"] &&
          ![file hasSuffix:@".analyzer"] &&
          ![file hasSuffix:@".plist"] &&
          ![file hasSuffix:@".data"] &&
          ![file hasSuffix:@".meta"] &&
          ![file hasSuffix:@".desc"]) {
        [self.crashFiles addObject:filePath];
      }
    }
  }

  if([self.crashFiles count] > 0) {
    MSAILog(@"INFO: %lu pending crash reports found.", (unsigned long) [self.crashFiles count]);
    return YES;
  } else {
    if(self.didCrashInLastSession) {
      _didCrashInLastSession = NO;
    }

    return NO;
  }
}

#pragma mark - Crash Report Processing

- (void)triggerDelayedProcessing {
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(invokeDelayedProcessing) object:nil];
  [self performSelector:@selector(invokeDelayedProcessing) withObject:nil afterDelay:0.5];
}

/**
* Delayed startup processing for everything that does not to be done in the app startup runloop
*
* - Checks if there is another exception handler installed that may block ours
* - Present UI if the user has to approve new crash reports
* - Send pending approved crash reports
*/
- (void)invokeDelayedProcessing {
  if(!msai_isRunningInAppExtension() &&
      [[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
    return;
  }

  MSAILog(@"INFO: Start delayed CrashManager processing");

  // was our own exception handler successfully added?
  if(self.exceptionHandler) {
    // get the current top level error handler
    NSUncaughtExceptionHandler *currentHandler = NSGetUncaughtExceptionHandler();

    // If the top level error handler differs from our own, then at least another one was added.
    // This could cause exception crashes not to be reported to AppInsights. See log message for details.
    if(self.exceptionHandler != currentHandler) {
      MSAILog(@"[AppInsights] WARNING: Another exception handler was added. If this invokes any kind exit() after processing the exception, which causes any subsequent error handler not to be invoked, these crashes will NOT be reported to AppInsights!");
    }
  }

  if(!self.sendingInProgress && [self hasPendingCrashReport]) {
    self.sendingInProgress = YES;

    NSString *notApprovedReportFilename = [self firstNotApprovedCrashReport];

    // this can happen in case there is a non approved crash report but it didn't happen in the previous app session
    if(notApprovedReportFilename && !self.lastCrashFilename) {
      self.lastCrashFilename = [notApprovedReportFilename lastPathComponent];
    }
    
    [self createCrashReport];
  }
}


/**
*  Creates a fake crash report because the app was killed while being in foreground
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

  MSAIEnvelope *fakeCrashEnvelope = [[MSAIEnvelopeManager sharedManager] envelope];
  fakeCrashEnvelope.data = data;
  fakeCrashEnvelope.name = crashData.envelopeTypeName;

  [[MSAIPersistence sharedInstance] persistFakeReportBundle:@[fakeCrashEnvelope]];
}

/***
* Gathers all collected data and constructs Crash into an Envelope for processing
*/
- (void)createCrashReport { //TODO rename this!
  NSError *error = NULL;

  if([self.crashFiles count] == 0)
    return;

  NSString *filename = self.crashFiles[0];
  NSString *cacheFilename = [filename lastPathComponent];
  NSData *crashData = [NSData dataWithContentsOfFile:filename];

  if([crashData length] > 0) {
    MSAIPLCrashReport *report = nil;
    MSAIEnvelope *crashEnvelope = nil;

    if([[cacheFilename pathExtension] isEqualToString:@"fake"]) {
      NSArray *fakeReportBundle = [[MSAIPersistence sharedInstance] fakeReportBundle];
      if(fakeReportBundle && fakeReportBundle.count > 0) {
        crashEnvelope = fakeReportBundle[0];
        if([crashEnvelope.appId compare:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]] == NSOrderedSame) {
        }
      }
    } else {
      report = [[MSAIPLCrashReport alloc] initWithData:crashData error:&error];
    }

    if(report == nil && crashEnvelope == nil) {
      MSAILog(@"WARNING: Could not parse crash report");
      // we cannot do anything with this report, so delete it
      [self cleanCrashReportWithFilename:filename];
      // we don't continue with the next report here, even if there are to prevent calling sendCrashReports from itself again
      // the next crash will be automatically send on the next app start/becoming active event
      return;
    }

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

    // store this crash report as user approved, so if it fails it will retry automatically
    self.approvedCrashReports[filename] = @YES; //TODO this can be removed

    [self saveSettings];

    [self processCrashReportWithFilename:filename envelope:crashEnvelope];
  } else {
    // we cannot do anything with this report, so delete it
    [self cleanCrashReportWithFilename:filename];
  }
}

/**
*	 Send the bundled up crash (in an envelope) over to the channel for persistence & sending
*
*	@param	filename the file that contains the crashreport
*	@param envelope the bundled up crash data
*/
- (void)processCrashReportWithFilename:(NSString *)filename envelope:(MSAIEnvelope *)envelope {

  MSAILog(@"INFO: Persisting crash reports started.");

  __weak typeof(self) weakSelf = self;
  [[MSAIChannel sharedChannel] processEnvelope:envelope withCompletionBlock:^(BOOL success) {
    typeof(self) strongSelf = weakSelf;

    self.sendingInProgress = NO;
    //TODO: sending is done in persistence layer --> notify user that crashes are available to be sent?!
    if(success) {
      [strongSelf cleanCrashReportWithFilename:filename];
      [strongSelf createCrashReport];
    }
  }];

  if(self.delegate != nil && [self.delegate respondsToSelector:@selector(crashManagerWillSendCrashReport)]) {
    [self.delegate crashManagerWillSendCrashReport];
  }
}

#pragma mark - Helpers

/**
* Save all settings
*
* This saves the list of approved crash reports
*/
- (void)saveSettings {
  NSError *error = nil;

  NSMutableDictionary *rootObj = [NSMutableDictionary dictionaryWithCapacity:2];
  if(self.approvedCrashReports && [self.approvedCrashReports count] > 0) {
    rootObj[kMSAICrashApprovedReports] = self.approvedCrashReports;
  }

  NSData *plist = [NSPropertyListSerialization dataWithPropertyList:(id) rootObj format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];

  if(plist) {
    [plist writeToFile:self.settingsFile atomically:YES];
  } else {
    MSAILog(@"ERROR: Writing settings. %@", [error description]);
  }
}


/**
* Load all settings
*
* This contains the list of approved crash reports
*/
- (void)loadSettings {
  NSError *error = nil;
  NSPropertyListFormat format;

  if(![self.fileManager fileExistsAtPath:self.settingsFile]) {
    return;
  }

  NSData *plist = [NSData dataWithContentsOfFile:self.settingsFile];
  if(plist) {
    NSDictionary *rootObj = (NSDictionary *) [NSPropertyListSerialization
        propertyListWithData:plist
                     options:NSPropertyListMutableContainersAndLeaves
                      format:&format
                       error:&error];

    if(rootObj[kMSAICrashApprovedReports])
      [self.approvedCrashReports setDictionary:rootObj[kMSAICrashApprovedReports]];
  } else {
    MSAILog(@"ERROR: Reading crash manager settings.");
  }
}

/**
*	 Remove all crash reports for each from the file system
*
* This is currently only used as a helper method for tests
*/
- (void)cleanCrashReports {
  for(NSUInteger i = 0; i < [self.crashFiles count]; i++) {
    [self cleanCrashReportWithFilename:self.crashFiles[i]];
  }
}

/**
* Remove a cached crash report
*
*  @param filename The base filename of the crash report
*/
- (void)cleanCrashReportWithFilename:(NSString *)filename {
  if(!filename) return;

  NSError *error = NULL;

  [self.fileManager removeItemAtPath:filename error:&error];
  [self.fileManager removeItemAtPath:[filename stringByAppendingString:@".data"] error:&error];
  [self.fileManager removeItemAtPath:[filename stringByAppendingString:@".meta"] error:&error];
  [self.fileManager removeItemAtPath:[filename stringByAppendingString:@".desc"] error:&error];

  [self.crashFiles removeObject:filename];
  [self.approvedCrashReports removeObjectForKey:filename];

  [self saveSettings];
}

//Safe info about safe termination of the app to NSUserDefaults
- (void)leavingAppSafely {
  if(self.appNotTerminatingCleanlyDetectionEnabled)
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMSAIAppWentIntoBackgroundSafely];
}

/**
* Stores info about didEnterBackground in NSUserDefaults.
*
*/

- (void)appEnteredForeground {
  // we disable kill detection while the debugger is running, since we'd get only false positives if the app is terminated by the user using the debugger
  if(self.debuggerIsAttached) {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMSAIAppWentIntoBackgroundSafely];
  } else if(self.appNotTerminatingCleanlyDetectionEnabled) {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kMSAIAppWentIntoBackgroundSafely];
  }
}

- (void)reportError:(NSError *)error {
  MSAILog(@"ERROR: %@", [error localizedDescription]);
}

@end

#endif /* MSAI_FEATURE_CRASH_REPORTER */

