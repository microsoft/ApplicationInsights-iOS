#import <Foundation/Foundation.h>
#import "AppInsightsFeatureConfig.h"

#if MSAI_FEATURE_CRASH_REPORTER
#import "MSAICrashManagerDelegate.h"
#endif

@class MSAIAppInsights;
@class MSAICrashManager;

/**
 The `MSAIManagerDelegate` formal protocol defines methods further configuring
  the behaviour of `MSAIManager`, as well as the delegate of the modules it manages.
 */

@protocol MSAIManagerDelegate <NSObject
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
 
    - (NSString *)userIDForManager:(MSAIManager *)Manager componentManager:(MSAICrashManager *)componentManager {
      if (componentManager == manager.feedbackManager) {
        return UserIDForFeedback;
      } else if (componentManager == manager.crashManager) {
        return UserIDForCrashReports;
      } else {
        return nil;
      }
    }
 
 For crash reports, this delegate is invoked on the startup after the crash!
 
 Alternatively you can also use `[MSAIManager userID]` which will cache the value in the keychain.

 @warning When returning a non nil value for the `MSAICrashManager` component, crash reports
 are not anonymous any more and the crash alerts will not show the word "anonymous"!
 
 @param manager The `MSAIManager` manager instance invoking this delegate
 @param componentManager The `MSAICrashManager` component instance invoking this delegate
 @see userNameForManager:componentManager:
 @see userEmailForManager:componentManager:
 @see [MSAIManager userID]
 */
- (NSString *)userIDForTelemetryManager:(MSAIAppInsights *)telemetryManager;


/** Return the user name that should used in the SDK components
 
 Right now this is used by the `MSAICrashManager` to attach to a crash report.
 `MSAIFeedbackManager` uses it too for assigning the user to a discussion thread.
 
 In addition, if this returns not nil for `MSAIFeedbackManager` the user will
 not be asked for any user details by the component, including useerName or userEmail.
 
 You can find out the component requesting the user name like this:
 
    - (NSString *)userNameForManager:(MSAIManager *)Manager componentManager:(MSAICrashManager *)componentManager {
      if (componentManager == manager.feedbackManager) {
        return UserNameForFeedback;
      } else if (componentManager == manager.crashManager) {
        return UserNameForCrashReports;
      } else {
        return nil;
      }
 }

 For crash reports, this delegate is invoked on the startup after the crash!
 
 Alternatively you can also use `[MSAIManager userName]` which will cache the value in the keychain.
 
 @warning When returning a non nil value for the `MSAICrashManager` component, crash reports
 are not anonymous any more and the crash alerts will not show the word "anonymous"!

 @param manager The `MSAIManager` manager instance invoking this delegate
 @param componentManager The `MSAICrashManager` component instance invoking this delegate, can be `MSAICrashManager` or `MSAIFeedbackManager`
 @see userIDForTelemetryManager:componentManager:
 @see userEmailForTelemetryManager:componentManager:
 @see [MSAIManager userName]
 */
- (NSString *)userNameForTelemetryManager:(MSAIAppInsights *)telemetryManager;


/** Return the users email address that should used in the SDK components
 
 Right now this is used by the `MSAICrashManager` to attach to a crash report.
 `MSAIFeedbackManager` uses it too for assigning the user to a discussion thread.
 
 In addition, if this returns not nil for `MSAIFeedbackManager` the user will
 not be asked for any user details by the component, including useerName or userEmail.
 
 You can find out the component requesting the user email like this:
 
    - (NSString *)userEmailForManager:(MSAIManager *)Manager componentManager:(MSAICrashManager *)componentManager {
      if (componentManager == manager.feedbackManager) {
        return UserEmailForFeedback;
      } else if (componentManager == manager.crashManager) {
        return UserEmailForCrashReports;
       } else {
        return nil;
       }
    }
 
 For crash reports, this delegate is invoked on the startup after the crash!
 
 Alternatively you can also use `[MSAIManager userEmail]` which will cache the value in the keychain.
 
 @warning When returning a non nil value for the `MSAICrashManager` component, crash reports
 are not anonymous any more and the crash alerts will not show the word "anonymous"!

 @param manager The `MSAIManager` manager instance invoking this delegate
 @param componentManager The `MSAICrashManager` component instance invoking this delegate, can be `MSAICrashManager` or `MSAIFeedbackManager`
 @see userIDForTelemetryManager:componentManager:
 @see userNameForTelemetryManager:componentManager:
 @see [MSAITelemetryTelemetryManager userEmail]
 */
- (NSString *)userEmailForTelemetryManager:(MSAIAppInsights *)telemetryManager;

@end
