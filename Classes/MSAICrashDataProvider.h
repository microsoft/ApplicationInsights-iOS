@class MSAIEnvelope;
@class MSAIPLCrashReport;

#import <Foundation/Foundation.h>
#import "ApplicationInsights.h"

MSAI_ASSUME_NONNULL_BEGIN
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

+ (MSAIEnvelope *)crashDataForCrashReport:(MSAIPLCrashReport *)report handledException:(MSAI_NULLABLE NSException *)exception;
+ (MSAIEnvelope *)crashDataForCrashReport:(MSAIPLCrashReport *)report;

@end
MSAI_ASSUME_NONNULL_END
