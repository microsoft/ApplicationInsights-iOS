#ifndef MSAI_h
#define MSAI_h

#import "ApplicationInsightsFeatureConfig.h"
#import "MSAIApplicationInsights.h"

#if MSAI_FEATURE_CRASH_REPORTER
#import "MSAICrashManager.h"
#import "MSAICrashManagerDelegate.h"
#import "MSAICrashDetails.h"
#import "MSAICrashMetaData.h"
#endif /* MSAI_FEATURE_CRASH_REPORTER */

#if MSAI_FEATURE_TELEMETRY
#import "MSAICategoryContainer.h"
#import "MSAITelemetryManager.h"
#endif /* MSAI_FEATURE_TELEMETRY */

// Notification message which MSAIApplicationInsights is listening to, to retry requesting updated from the server
#define MSAINetworkDidBecomeReachableNotification @"MSAINetworkDidBecomeReachable"

#define MSAI_BASE_URL   @"https://dc.services.visualstudio.com"

#if MSAI_FEATURE_CRASH_REPORTER
NS_ASSUME_NONNULL_BEGIN
/**
 *  MSAI Crash Reporter error domain
 */
typedef NS_ENUM (NSInteger, MSAICrashErrorReason) {
  /**
   *  Unknown error
   */
  MSAICrashErrorUnknown,
  /**
   *  API Server rejected app version
   */
  MSAICrashAPIAppVersionRejected,
  /**
   *  API Server returned empty response
   */
  MSAICrashAPIReceivedEmptyResponse,
  /**
   *  Connection error with status code
   */
  MSAICrashAPIErrorWithStatusCode
};
extern NSString *const __unused kMSAICrashErrorDomain;


/**
 *  MSAI global error domain
 */
typedef NS_ENUM(NSInteger, MSAIErrorReason) {
  /**
   *  Unknown error
   */
  MSAIErrorUnknown
};
extern NSString *const __unused kMSAIErrorDomain;
NS_ASSUME_NONNULL_END
#endif 

#endif
