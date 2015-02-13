#import <Foundation/Foundation.h>
#import "AppInsightsFeatureConfig.h"

#if MSAI_FEATURE_CRASH_REPORTER
#import "MSAICrashManagerDelegate.h"
#endif

@class MSAITelemetryManager;
@class MSAIBaseManager;

/**
 The `MSAITelemetryManagerDelegate` formal protocol defines methods further configuring
  the behaviour of `MSAITelemetryManager`, as well as the delegate of the modules it manages.
 */

@protocol MSAITelemetryManagerDelegate <NSObject
#if MSAI_FEATURE_CRASH_REPORTER
  , MSAICrashManagerDelegate
#endif
  >

@optional


///-----------------------------------------------------------------------------
/// @name Additional meta data
///-----------------------------------------------------------------------------


/** Return the userid that should used in the SDK components
 
 Right now this is used by the `MSAICrashManager` to attach to a crash report.
 `MSAIFeedbackManager` uses it too for assigning the user to a discussion thread.
 
 In addition, if this returns not nil for `MSAIFeedbackManager` the user will
 not be asked for any user details by the component, including useerName or userEmail.
 
 You can find out the component requesting the userID like this:
 
    - (NSString *)userIDForManager:(MSAITelemetryManager *)Manager componentManager:(MSAIBaseManager *)componentManager {
      if (componentManager == manager.feedbackManager) {
        return UserIDForFeedback;
      } else if (componentManager == manager.crashManager) {
        return UserIDForCrashReports;
      } else {
        return nil;
      }
    }
 
 For crash reports, this delegate is invoked on the startup after the crash!
 
 Alternatively you can also use `[MSAITelemetryManager userID]` which will cache the value in the keychain.

 @warning When returning a non nil value for the `MSAICrashManager` component, crash reports
 are not anonymous any more and the crash alerts will not show the word "anonymous"!
 
 @param manager The `MSAITelemetryManager` manager instance invoking this delegate
 @param componentManager The `MSAIBaseManager` component instance invoking this delegate, can be `MSAICrashManager` or `MSAIFeedbackManager`
 @see userNameForManager:componentManager:
 @see userEmailForManager:componentManager:
 @see [MSAITelemetryManager userID]
 */
- (NSString *)userIDForTelemetryManager:(MSAITelemetryManager *)telemetryManager componentManager:(MSAIBaseManager *)componentManager;


/** Return the user name that should used in the SDK components
 
 Right now this is used by the `MSAICrashManager` to attach to a crash report.
 `MSAIFeedbackManager` uses it too for assigning the user to a discussion thread.
 
 In addition, if this returns not nil for `MSAIFeedbackManager` the user will
 not be asked for any user details by the component, including useerName or userEmail.
 
 You can find out the component requesting the user name like this:
 
    - (NSString *)userNameForManager:(MSAITelemetryManager *)Manager componentManager:(MSAIBaseManager *)componentManager {
      if (componentManager == manager.feedbackManager) {
        return UserNameForFeedback;
      } else if (componentManager == manager.crashManager) {
        return UserNameForCrashReports;
      } else {
        return nil;
      }
 }

 For crash reports, this delegate is invoked on the startup after the crash!
 
 Alternatively you can also use `[MSAITelemetryManager userName]` which will cache the value in the keychain.
 
 @warning When returning a non nil value for the `MSAICrashManager` component, crash reports
 are not anonymous any more and the crash alerts will not show the word "anonymous"!

 @param manager The `MSAITelemetryManager` manager instance invoking this delegate
 @param componentManager The `MSAIBaseManager` component instance invoking this delegate, can be `MSAICrashManager` or `MSAIFeedbackManager`
 @see userIDForTelemetryManager:componentManager:
 @see userEmailForTelemetryManager:componentManager:
 @see [MSAITelemetryManager userName]
 */
- (NSString *)userNameForTelemetryManager:(MSAITelemetryManager *)telemetryManager componentManager:(MSAIBaseManager *)componentManager;


/** Return the users email address that should used in the SDK components
 
 Right now this is used by the `MSAICrashManager` to attach to a crash report.
 `MSAIFeedbackManager` uses it too for assigning the user to a discussion thread.
 
 In addition, if this returns not nil for `MSAIFeedbackManager` the user will
 not be asked for any user details by the component, including useerName or userEmail.
 
 You can find out the component requesting the user email like this:
 
    - (NSString *)userEmailForManager:(MSAITelemetryManager *)Manager componentManager:(MSAIBaseManager *)componentManager {
      if (componentManager == manager.feedbackManager) {
        return UserEmailForFeedback;
      } else if (componentManager == manager.crashManager) {
        return UserEmailForCrashReports;
       } else {
        return nil;
       }
    }
 
 For crash reports, this delegate is invoked on the startup after the crash!
 
 Alternatively you can also use `[MSAITelemetryManager userEmail]` which will cache the value in the keychain.
 
 @warning When returning a non nil value for the `MSAICrashManager` component, crash reports
 are not anonymous any more and the crash alerts will not show the word "anonymous"!

 @param manager The `MSAITelemetryManager` manager instance invoking this delegate
 @param componentManager The `MSAIBaseManager` component instance invoking this delegate, can be `MSAICrashManager` or `MSAIFeedbackManager`
 @see userIDForTelemetryManager:componentManager:
 @see userNameForTelemetryManager:componentManager:
 @see [MSAITelemetryTelemetryManager userEmail]
 */
- (NSString *)userEmailForTelemetryManager:(MSAITelemetryManager *)telemetryManager componentManager:(MSAIBaseManager *)componentManager;

@end
