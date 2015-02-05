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
 
 The delegate is automatically set by using `[MSAITelemetryManager setDelegate:]`. You
 should not need to set this delegate individually.
 
 @see `[MSAITelemetryManager setDelegate:]`
 */
@property (nonatomic, weak) id delegate;

/**
 * must be set
 */

@property (nonatomic) NSUncaughtExceptionHandler *exceptionHandler;

@property (nonatomic, strong) NSFileManager *fileManager;

@property (nonatomic, strong) MSAIPLCrashReporter *plCrashReporter;

@property (nonatomic) NSString *lastCrashFilename;

@property (nonatomic, copy, setter = setAlertViewHandler:) MSAICustomAlertViewHandler alertViewHandler;

@property (nonatomic, strong) NSString *crashesDir;

- (void)cleanCrashReports;

- (NSString *)userIDForCrashReport;
- (NSString *)userEmailForCrashReport;
- (NSString *)userNameForCrashReport;

- (void)handleCrashReport;
- (BOOL)hasPendingCrashReport;
- (NSString *)firstNotApprovedCrashReport;

- (void)persistUserProvidedMetaData:(MSAICrashMetaData *)userProvidedMetaData;

- (void)invokeDelayedProcessing;
- (void)sendNextCrashReport;

- (void)setLastCrashFilename:(NSString *)lastCrashFilename;

@end


#endif /* MSAI_FEATURE_CRASH_REPORTER */
