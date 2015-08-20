
#import "ApplicationInsightsFeatureConfig.h"
#import "MSAINullability.h"
#import "MSAIApplicationInsights.h"
#import "MSAINamespace.h"

#if MSAI_FEATURE_CRASH_REPORTER
#import "MSAICrashManager.h"
#import "MSAICrashManagerDelegate.h"
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

#if defined(__cplusplus)
#  if defined(MSAI_SDK_PREFIX)
/** @internal Define the msai namespace, automatically inserting an inline namespace containing the configured MSAI_SDK_PREFIX, if any. */
#    define PLCR_CPP_BEGIN_NS namespace msai { inline namespace MSAI_SDK_PREFIX {

/** @internal Close the definition of the `msai` namespace (and the MSAI_SDK_PREFIX inline namespace, if any). */
#    define PLCR_CPP_END_NS }}
#  else
#   define PLCR_CPP_BEGIN_NS namespace msai {
#   define PLCR_CPP_END_NS }
#  endif
#
#endif



