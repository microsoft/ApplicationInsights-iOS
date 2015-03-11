#import <Foundation/Foundation.h>
#import "MSAIAppInsights.h"

#ifndef MSAI_Private_h
#define MSAI_Private_h

extern NSString *const kMSAIName;
extern NSString *const kMSAIIdentifier;
extern NSString *const kMSAICrashSettings;
extern NSString *const kMSAICrashAnalyzer;

#if MSAI_FEATURE_METRICS

extern NSString *const __attribute__((unused)) kMSAIMetricsCachesSessions;
extern NSString *const __attribute__((unused)) kMSAIMetricsTempSessionData;
extern NSString *const __attribute__((unused)) kMSAIMetricsLastAppVersion;

#endif

extern NSString *const kMSAIIntegrationflowTimestamp;

#define MSAI_SDK_URL          MSAI_EVENT_DATA_URL
extern NSString *const kMSAITelemetryPath;

#define MSAILog(fmt, ...) do { if([MSAIAppInsights sharedInstance].isDebugLogEnabled && ![MSAIAppInsights sharedInstance].isAppStoreEnvironment) { NSLog((@"[MSAI] %s/%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }} while(0)

#ifndef __IPHONE_8_0
#define __IPHONE_8_0     80000
#endif

#endif //MSAI_Private_h
