#import <Foundation/Foundation.h>

/**
 *  The `MSAIAppInsightsDelegate` formal protocol defines methods further configuring the behaviour of 
 *  `MSAIAppInsights`.
 */
@protocol MSAIAppInsightsDelegate <NSObject>

@optional

#if MSAI_FEATURE_CRASH_REPORTER

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
 
 @return `YES` if the heuristic based detected report should be reported, otherwise `NO`
 @see `[MSAICrashManager didReceiveMemoryWarningInLastSession]`
 */
- (BOOL)considerAppNotTerminatedCleanlyReportForCrashManager;
//not implemented as property as users want to implement logic

///-----------------------------------------------------------------------------
/// @name Sending crash data
///-----------------------------------------------------------------------------

//Reason for this: http://support.hockeyapp.net/kb/client-integration-ios-mac-os-x/how-to-handle-crashes-during-startup-on-ios

/**
 *  Invoked before sending crash reports succeeded.
 *
 *  @param crashDict the crash as dictionary
 */
- (void)appInsightsWillSendCrashDict:(NSDictionary *)crashDict;

/**
 *  Invoked after sending crash reports succeeded.
 *
 *  @param crashDict the crash as dictionary
 */
- (void)appInsightsDidFinishSendingCrashDict:(NSDictionary *)crashDict;

#endif /* MSAI_FEATURE_CRASH_REPORTER */

///-----------------------------------------------------------------------------
/// @name Common network failure
///-----------------------------------------------------------------------------

/**
 *  Invoked after sending crash reports failed.
 *
 *  @param error The error returned from the NSURLConnection call or `kMSAICrashErrorDomain` with reason of type 
 *  `MSAICrashErrorReason`
 */
- (void)appInsightsDidFailWithError:(NSError *)error;

@end
