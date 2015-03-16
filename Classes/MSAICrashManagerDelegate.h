#import <Foundation/Foundation.h>

@class MSAICrashManager;

NS_ASSUME_NONNULL_BEGIN
/**
The `MSAICrashManagerDelegate` formal protocol defines methods further configuring
the behaviour of `MSAICrashManager`.
*/
@protocol MSAICrashManagerDelegate <NSObject>

@optional

///-----------------------------------------------------------------------------
/// @name Networking
///-----------------------------------------------------------------------------

//Reason for this: http://support.hockeyapp.net/kb/client-integration-ios-mac-os-x/how-to-handle-crashes-during-startup-on-ios

/** Invoked right before sending crash reports will start
*/
- (void)crashManagerWillSendCrashReport; //TODO this should be part of the MSAISenderDelegate

/** Invoked after sending crash reports failed

@param error The error returned from the NSURLConnection call or `kMSAICrashErrorDomain`
with reason of type `MSAICrashErrorReason`.
*/
- (void)crashManagerDidFailWithError:(NSError *)error;

/** Invoked after sending crash reports succeeded
*/
- (void)crashManagerDidFinishSendingCrashReport;

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


@end
NS_ASSUME_NONNULL_END
