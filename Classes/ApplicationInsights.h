#ifndef MSAI_h
#define MSAI_h

// Define nullability fallback for backwards compatibility
#if __has_feature(nullability)
#define MSAI_ASSUME_NONNULL_BEGIN _Pragma("clang assume_nonnull begin")
#define MSAI_ASSUME_NONNULL_END _Pragma("clang assume_nonnull end")
#define MSAI___NONNULL __nonnull
#define MSAI___NULLABLE __nullable
#define MSAI___NULL_UNSPECIFIED __null_unspecified
#define MSAI___NULL_RESETTABLE __null_resettable
#define MSAI_NONNULL nonnull
#define MSAI_NULLABLE nullable
#define MSAI_NULL_UNSPECIFIED null_unspecified
#define MSAI_NULL_RESETTABLE null_resettable
#else
#define MSAI_ASSUME_NONNULL_BEGIN
#define MSAI_ASSUME_NONNULL_END
#define MSAI___NONNULL
#define MSAI___NULLABLE
#define MSAI___NULL_UNSPECIFIED
#define MSAI___NULL_RESETTABLE
#define MSAI_NONNULL
#define MSAI_NULLABLE
#define MSAI_NULL_UNSPECIFIED
#define MSAI_NULL_RESETTABLE
#endif

#import "ApplicationInsightsFeatureConfig.h"
#import "MSAIApplicationInsights.h"
#import "MSAICategoryContainer.h"

#if MSAI_FEATURE_CRASH_REPORTER
#import "MSAICrashManager.h"
#import "MSAICrashManagerDelegate.h"
#import "MSAICrashDetails.h"
#endif /* MSAI_FEATURE_CRASH_REPORTER */

#if MSAI_FEATURE_TELEMETRY
#import "MSAITelemetryManager.h"
#endif /* MSAI_FEATURE_TELEMETRY */

// Notification message which MSAIApplicationInsights is listening to, to retry requesting updated from the server
#define MSAINetworkDidBecomeReachableNotification @"MSAINetworkDidBecomeReachable"

#define MSAI_SERVER_URL   @"https://dc.services.visualstudio.com/v2/track"

#if MSAI_FEATURE_CRASH_REPORTER
MSAI_ASSUME_NONNULL_BEGIN
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
MSAI_ASSUME_NONNULL_END

#endif /* MSAI_FEATURE_CRASH_REPORTER */

#endif /* MSAI_h */
