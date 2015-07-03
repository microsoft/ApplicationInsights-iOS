#import "ApplicationInsights.h"
#import "MSAICrashDataProvider.h"
#import "MSAINullability.h"

@class MSAIEnvelope;
@class MSAIPLCrashReport;
@class MSAIExceptionData;
@class MSAIStackFrame;

NS_ASSUME_NONNULL_BEGIN
/**
 *  ApplicationInsights Crash Reporter error domain
 */
typedef NS_ENUM (NSInteger, MSAIBinaryImageType) {
  /**
   *  App binary
   */
  MSAIBinaryImageTypeAppBinary,
  /**
   *  App provided framework
   */
  MSAIBinaryImageTypeAppFramework,
  /**
   *  Image not related to the app
   */
  MSAIBinaryImageTypeOther
};

@interface MSAICrashDataProvider () {}

+ (MSAIEnvelope *)crashDataForCrashReport:(MSAIPLCrashReport *)report handledException:(nullable NSException *)exception;

+ (MSAIEnvelope *)crashDataForCrashReport:(MSAIPLCrashReport *)report;

#if MSAI_FEATURE_XAMARIN

+ (MSAIStackFrame *)stackframeForStackLine:(NSString *)stackLine;

+ (MSAIExceptionData *)exceptionDataForExceptionWithType:(NSString *)type
                                                 message:(NSString *)message
                                              stacktrace:(NSString *)stacktrace
                                                 handled:(BOOL)handled;



#endif /* MSAI_FEATURE_XAMARIN */

@end
NS_ASSUME_NONNULL_END