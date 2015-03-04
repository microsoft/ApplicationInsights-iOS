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
@property (nonatomic, weak) id delegate; //TODO Will be removed eventually

@property (nonatomic, assign) PLCrashReporterCallbacks *crashCallBacks;
@property (nonatomic, strong) MSAIContext *appContext;
@property (nonatomic, strong) MSAIPLCrashReporter *plCrashReporter;
@property (nonatomic, assign) BOOL didLogLowMemoryWarning;
@property (nonatomic, assign) NSUncaughtExceptionHandler *exceptionHandler;

/**
*  This method is used to setup the CrashManager-Module of the Application Insights SDK.
*  This method is called by MSAIManager during it's initialization, so calling this by hand
*  shouldn't be necessary in most cases.
*
*  @param context the MSAIContext object
*/
+ (void)startWithContext:(MSAIContext *)context;

- (void)startManager;

- (void)checkCrashManagerDisabled;

- (void)readCrashReportAndStartProcessing;

- (void)createCrashReportForAppKill;

- (void)createCrashReportWithCrashData:(NSData*)crashData;

- (void)leavingAppSafely;

- (void)appEnteredForeground;

/**
* by default, just logs the message
*
* can be overridden by subclasses to do their own error handling,
* e.g. to show UI
*
* @param error NSError
*/
- (void)reportError:(NSError *)error;

@end


#endif /* MSAI_FEATURE_CRASH_REPORTER */
