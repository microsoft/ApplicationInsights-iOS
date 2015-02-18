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

/**
 * must be set
 */


  //TODO remove and/or move to setter methods!

//@property (nonatomic) NSUncaughtExceptionHandler *exceptionHandler;

+ (NSUncaughtExceptionHandler *)getExceptionHandler;
+ (void)setExceptionHandler:(NSUncaughtExceptionHandler*)exceptionHandler;

//@property (nonatomic, strong) NSFileManager *fileManager;

+ (NSFileManager *)getFileManager;
+ (void)setFileManager:(NSFileManager *)fileManager;

//@property (nonatomic, strong) MSAIPLCrashReporter *plCrashReporter;

+ (MSAIPLCrashReporter *)getPLCrashReporter;
+ (void)setPLCrashReporter:(MSAIPLCrashReporter *)crashReporter;

//@property (nonatomic) NSString *lastCrashFilename;

+ (NSString *)getLastCrashFilename;
+ (void)setLastCrashFilename:(NSString *)lastCrashFilename;

//@property (nonatomic, copy, setter = setAlertViewHandler:) MSAICustomAlertViewHandler alertViewHandler;

+ (MSAICustomAlertViewHandler)getAlertViewHandler;
+ (void)setAlertViewHandler:(MSAICustomAlertViewHandler)alertViewHandler;

//@property (nonatomic, strong) NSString *crashesDir;

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

+ (void)setLastCrashFilename:(NSString *)lastCrashFilename;



//@property(nonatomic, strong) MSAIContext *appContext;

//- (instancetype)initWithAppContext:(MSAIContext *)appContext;

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

// Date helpers
//- (NSDate *)parseRFC3339Date:(NSString *)dateString;

  //TODO REMOVE
// keychain helpers
//+ (BOOL)addStringValueToKeychain:(NSString *)stringValue forKey:(NSString *)key;
//+ (BOOL)addStringValueToKeychainForThisDeviceOnly:(NSString *)stringValue forKey:(NSString *)key;
//+ (NSString *)stringValueFromKeychainForKey:(NSString *)key;
//+ (BOOL)removeKeyFromKeychain:(NSString *)key;



@end


#endif /* MSAI_FEATURE_CRASH_REPORTER */
