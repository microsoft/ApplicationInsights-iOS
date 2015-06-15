#import <Foundation/Foundation.h>
#import "MSAINullability.h"

@class MSAIEnvelope;
@class MSAIPLCrashReport;

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

+ (MSAIEnvelope *)crashDataForCrashReport:(MSAIPLCrashReport *)report handledException:(nullable NSException *)exception;
+ (MSAIEnvelope *)crashDataForCrashReport:(MSAIPLCrashReport *)report;

@end
NS_ASSUME_NONNULL_END
