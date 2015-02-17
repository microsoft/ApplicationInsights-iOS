#import <Foundation/Foundation.h>

@class MSAICrashManager;

/**
 The `MSAICrashManagerDelegate` formal protocol defines methods further configuring
 the behaviour of `MSAICrashManager`.
 */

@protocol MSAICrashManagerDelegate <NSObject>

@optional


///-----------------------------------------------------------------------------
/// @name Additional meta data
///-----------------------------------------------------------------------------

/** Return any log string based data the crash report being processed should contain

 @param crashManager The `MSAICrashManager` instance invoking this delegate
 @see attachmentForCrashManager:
 @see userNameForCrashManager:
 @see userEmailForCrashManager:
 */
-(NSString *)applicationLogForCrashManager:(MSAICrashManager *)crashManager;



/** Return the user name or userid that should be send along each crash report
 
 @param crashManager The `MSAICrashManager` instance invoking this delegate
 @see applicationLogForCrashManager:
 @see attachmentForCrashManager:
 @see userEmailForCrashManager:
 @deprecated Please use `MSAIManagerDelegate userNameForManager:componentManager:` instead
 @warning When returning a non nil value, crash reports are not anonymous any
 more and the alerts will not show the "anonymous" word!
 */
-(NSString *)userNameForCrashManager:(MSAICrashManager *)crashManager DEPRECATED_ATTRIBUTE;



/** Return the users email address that should be send along each crash report
 
 @param crashManager The `MSAICrashManager` instance invoking this delegate
 @see applicationLogForCrashManager:
 @see attachmentForCrashManager:
 @see userNameForCrashManager:
 @deprecated Please use `MSAIManagerDelegate userEmailForManager:componentManager:` instead
 @warning When returning a non nil value, crash reports are not anonymous any
 more and the alerts will not show the "anonymous" word!
 */
-(NSString *)userEmailForCrashManager:(MSAICrashManager *)crashManager DEPRECATED_ATTRIBUTE;



///-----------------------------------------------------------------------------
/// @name Alert
///-----------------------------------------------------------------------------

/** Invoked before the user is asked to send a crash report, so you can do additional actions.
 E.g. to make sure not to ask the user for an app rating :)
 
 @param crashManager The `MSAICrashManager` instance invoking this delegate
 */
-(void)crashManagerWillShowSubmitCrashReportAlert:(MSAICrashManager *)crashManager;


/** Invoked after the user did choose _NOT_ to send a crash in the alert
 
 @param crashManager The `MSAICrashManager` instance invoking this delegate
 */
-(void)crashManagerWillCancelSendingCrashReport:(MSAICrashManager *)crashManager;


/** Invoked after the user did choose to send crashes always in the alert
 
 @param crashManager The `MSAICrashManager` instance invoking this delegate
 */
-(void)crashManagerWillSendCrashReportsAlways:(MSAICrashManager *)crashManager;


///-----------------------------------------------------------------------------
/// @name Networking
///-----------------------------------------------------------------------------

/** Invoked right before sending crash reports will start
 
 @param crashManager The `MSAICrashManager` instance invoking this delegate
 */
- (void)crashManagerWillSendCrashReport:(MSAICrashManager *)crashManager;

/** Invoked after sending crash reports failed
 
 @param crashManager The `MSAICrashManager` instance invoking this delegate
 @param error The error returned from the NSURLConnection call or `kMSAICrashErrorDomain`
 with reason of type `MSAICrashErrorReason`.
 */
- (void)crashManager:(MSAICrashManager *)crashManager didFailWithError:(NSError *)error;

/** Invoked after sending crash reports succeeded
 
 @param crashManager The `MSAICrashManager` instance invoking this delegate
 */
- (void)crashManagerDidFinishSendingCrashReport:(MSAICrashManager *)crashManager;

///-----------------------------------------------------------------------------
/// @name Experimental
///-----------------------------------------------------------------------------

/** Define if a report should be considered as a crash report
 
 Due to the risk, that these reports may be false positives, this delegates allows the
 developer to influence which reports detected by the heuristic should actually be reported.
 
 The developer can use the following property to get more information about the crash scenario:
 - `[MSAICrashManager didReceiveMemoryWarningInLastSession]`: Did the app receive a low memory warning
 
 This allows only reports to be considered where at least one low memory warning notification was
 received by the app to reduce to possibility of having false positives.
 
 @param crashManager The `MSAICrashManager` instance invoking this delegate
 @return `YES` if the heuristic based detected report should be reported, otherwise `NO`
 @see `[MSAICrashManager didReceiveMemoryWarningInLastSession]`
 */
-(BOOL)considerAppNotTerminatedCleanlyReportForCrashManager:(MSAICrashManager *)crashManager;

@end
