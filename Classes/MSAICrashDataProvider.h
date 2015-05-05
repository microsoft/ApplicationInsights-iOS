@class MSAIEnvelope;
@class PLCrashReport;

#import <Foundation/Foundation.h>
#import "ApplicationInsights.h"

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


@interface MSAICrashDataProvider : NSObject {
}

+ (MSAIEnvelope *)crashDataForCrashReport:(PLCrashReport *)report handledException:(nullable NSException *)exception;
+ (MSAIEnvelope *)crashDataForCrashReport:(PLCrashReport *)report;

@end
NS_ASSUME_NONNULL_END
