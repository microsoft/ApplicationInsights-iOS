@class MSAIEnvelope;
@class PLCrashReport;

#import <Foundation/Foundation.h>

// Dictionary keys for array elements returned by arrayOfAppUUIDsForCrashReport:
#ifndef kMSAIBinaryImageKeyUUID
#define kMSAIBinaryImageKeyUUID @"uuid"
#define kMSAIBinaryImageKeyArch @"arch"
#define kMSAIBinaryImageKeyType @"type"
#endif


/**
 *  AppInsights Crash Reporter error domain
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

+ (MSAIEnvelope *)crashDataForCrashReport:(PLCrashReport *)report handledException:(NSException *)exception;
+ (MSAIEnvelope *)crashDataForCrashReport:(PLCrashReport *)report;
+ (NSArray *)arrayOfAppUUIDsForCrashReport:(PLCrashReport *)report;
+ (NSString *)msai_archNameFromCPUType:(uint64_t)cpuType subType:(uint64_t)subType;
+ (MSAIBinaryImageType)msai_imageTypeForImagePath:(NSString *)imagePath processPath:(NSString *)processPath;

@end
