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
@property (nonatomic, weak) id delegate; //TODO Do we need this at all
@property (nonatomic, assign) PLCrashReporterCallbacks *crashCallBacks;
@property (nonatomic, strong) NSFileManager *fileManager; //TODO shouldn't we no longer use this?!
@property (nonatomic, strong) MSAIContext *appContext;
@property (nonatomic, strong) NSMutableArray *crashFiles; //TODO shouldn't we no longer use this?!
@property (nonatomic, strong) NSMutableDictionary *approvedCrashReports;
@property (nonatomic, copy) NSString *settingsFile; //TODO shouldn't we move this to Persistence?
@property (nonatomic, copy) NSString *crashesDir;
@property (nonatomic, copy) NSString *lastCrashFilename;
@property (nonatomic, strong) MSAIPLCrashReporter *plCrashReporter;
@property (nonatomic, assign) BOOL didLogLowMemoryWarning;
@property (nonatomic, assign) BOOL sendingInProgress;
@property (nonatomic, copy) NSString *analyzerInProgressFile;
@property (nonatomic, assign) NSUncaughtExceptionHandler *exceptionHandler;


- (void)startManager;

- (void)initValues;

- (void)storeMetaDataForCrashReportFilename:(NSString *)filename;

- (NSString *)userIDForCrashReport;

- (NSString *)userNameForCrashReport;

- (NSString *)userEmailForCrashReport;

- (void)handleCrashReport;

- (NSString *)firstNotApprovedCrashReport;

- (BOOL)hasPendingCrashReport;

- (void)invokeDelayedProcessing;

- (void)createCrashReportForAppKill;

- (void)sendNextCrashReport;

- (void)processCrashReportWithFilename:(NSString *)filename envelope:(MSAIEnvelope *)envelope;

- (void)saveSettings;

- (void)loadSettings;

- (void)cleanCrashReports;

- (void)cleanCrashReportWithFilename:(NSString *)filename;

- (void)persistUserProvidedMetaData:(MSAICrashMetaData *)userProvidedMetaData;

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



//TODO what did this mean? likely to refer to Context object
/**
* must be set
*/












@end


#endif /* MSAI_FEATURE_CRASH_REPORTER */
