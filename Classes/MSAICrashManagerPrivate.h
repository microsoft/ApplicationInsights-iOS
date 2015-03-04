#import "AppInsights.h"

#if MSAI_FEATURE_CRASH_REPORTER

#import <CrashReporter/CrashReporter.h>

@class MSAIAppClient;
@class MSAIEnvelope;

@interface MSAICrashManager () {
}


///-----------------------------------------------------------------------------
/// @name Delegate
///-----------------------------------------------------------------------------

/**
Sets the optional `MSAICrashManagerDelegate` delegate.

The delegate is automatically set by using `[MSAIManager setDelegate:]`. You
should not need to set this delegate individually.

@see `[MSAIManager setDelegate:]`
*/
@property (nonatomic, weak) id delegate; //TODO Will be removed eventually?

@property (nonatomic, assign) PLCrashReporterCallbacks *crashCallBacks;
@property (nonatomic, strong) NSFileManager *fileManager; //TODO remove when we refactor the persistence stuff out of crashmanager
@property (nonatomic, strong) NSMutableArray *crashFiles; //TODO remove when we refactor the persistence stuff out of crashmanager
@property (nonatomic, strong) NSMutableDictionary *approvedCrashReports;
@property (nonatomic, copy) NSString *settingsFile; //TODO remove when we refactor the persistence stuff out of crashmanager
@property (nonatomic, copy) NSString *crashesDir; //TODO remove when we refactor the persistence stuff out of crashmanager
@property (nonatomic, copy) NSString *lastCrashFilename;
@property (nonatomic, strong) MSAIPLCrashReporter *plCrashReporter;
@property (nonatomic, assign) BOOL didLogLowMemoryWarning;
@property (nonatomic, assign) BOOL sendingInProgress;
@property (nonatomic, copy) NSString *analyzerInProgressFile;
@property (nonatomic, assign) NSUncaughtExceptionHandler *exceptionHandler;

/**
*  This method is used to setup the CrashManager-Module of the Application Insights SDK.
*  This method is called by MSAIManager during it's initialization, so calling this by hand
*  shouldn't be necessary in most cases.
*
*  @param context the MSAIContext object
*/

- (void)startManager;

- (void)initValues;

- (void)handleCrashReport;

- (NSString *)firstNotApprovedCrashReport;

- (BOOL)hasPendingCrashReport;

- (void)invokeDelayedProcessing;

- (void)createCrashReportForAppKill;

- (void)createCrashReport;

- (void)processCrashReportWithFilename:(NSString *)filename envelope:(MSAIEnvelope *)envelope;

- (void)saveSettings;

- (void)loadSettings;

- (void)cleanCrashReports;

- (void)cleanCrashReportWithFilename:(NSString *)filename;

- (void)leavingAppSafely;

- (void)appEnteredForeground;

/**
* by default, just logs the message
*
* can be overriden by subclasses to do their own error handling,
* e.g. to show UI
*
* @param error NSError
*/
- (void)reportError:(NSError *)error;

@end


#endif /* MSAI_FEATURE_CRASH_REPORTER */
