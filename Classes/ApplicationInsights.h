#ifndef MSAI_h
#define MSAI_h

// Define nullability fallback for backwards compatibility
#if !__has_feature(nullability)
#define NS_ASSUME_NONNULL_BEGIN
#define NS_ASSUME_NONNULL_END
#define nullable
#define nonnull
#define null_unspecified
#define null_resettable
#define __nullable
#define __nonnull
#define __null_unspecified
#endif

#import "ApplicationInsightsFeatureConfig.h"
#import "MSAIApplicationInsights.h"
#import "MSAICategoryContainer.h"

#if MSAI_FEATURE_CRASH_REPORTER
#import "MSAICrashManager.h"
#import "MSAICrashDetails.h"
#endif /* MSAI_FEATURE_CRASH_REPORTER */

#if MSAI_FEATURE_TELEMETRY
#import "MSAITelemetryManager.h"
#endif /* MSAI_FEATURE_TELEMETRY */

// Notification message which MSAIApplicationInsights is listening to, to retry requesting updated from the server
#define MSAINetworkDidBecomeReachableNotification @"MSAINetworkDidBecomeReachable"

#define MSAI_SERVER_URL   @"https://dc.services.visualstudio.com/v2/track"

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
FOUNDATION_EXPORT NSString *const __unused kMSAICrashErrorDomain;


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

#endif /* MSAI_FEATURE_CRASH_REPORTER */

#endif /* MSAI_h */
