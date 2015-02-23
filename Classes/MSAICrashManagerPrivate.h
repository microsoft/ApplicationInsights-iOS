#import "AppInsights.h"

#if MSAI_FEATURE_CRASH_REPORTER

#import <CrashReporter/CrashReporter.h>

@class MSAIAppClient;

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
//@property (nonatomic, weak) id delegate;


+ (void)setDelegate:(id)delegate;

+ (id)getDelegate;

//TODO what does this mean?
/**
* must be set
*/

+ (NSUncaughtExceptionHandler *)getExceptionHandler;

+ (void)setExceptionHandler:(NSUncaughtExceptionHandler *)exceptionHandler;

+ (NSFileManager *)getFileManager;

+ (void)setFileManager:(NSFileManager *)fileManager;

+ (MSAIPLCrashReporter *)getPLCrashReporter;

+ (void)setPLCrashReporter:(MSAIPLCrashReporter *)crashReporter;

+ (NSString *)getLastCrashFilename;

+ (void)setLastCrashFilename:(NSString *)lastCrashFilename;


+ (NSString *)getCrashesDir;

+ (void)setCrashesDir:(NSString *)crashesDir;

+ (void)cleanCrashReports;

+ (NSString *)userIDForCrashReport;

+ (NSString *)userEmailForCrashReport;

+ (NSString *)userNameForCrashReport;

+ (void)handleCrashReport;

+ (BOOL)hasPendingCrashReport;

+ (NSString *)firstNotApprovedCrashReport;

+ (void)persistUserProvidedMetaData:(MSAICrashMetaData *)userProvidedMetaData;

+ (void)invokeDelayedProcessing;

+ (void)sendNextCrashReport;

+ (void)setAppContext:(MSAIContext *)context;

+ (MSAIContext *)getAppContext;

+ (NSString *)executableUUID;

/**
* by default, just logs the message
*
* can be overriden by subclasses to do their own error handling,
* e.g. to show UI
*
* @param error NSError
*/
+ (void)reportError:(NSError *)error;


@end


#endif /* MSAI_FEATURE_CRASH_REPORTER */
