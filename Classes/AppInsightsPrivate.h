#import <Foundation/Foundation.h>

#ifndef MSAI_Private_h
#define MSAI_Private_h

#define MSAI_NAME @"AppInsights-iOS"
#define MSAI_IDENTIFIER @"com.microsoft.applicationinsights.ios"
#define MSAI_CRASH_SETTINGS @"MSAICrashManager.plist"
#define MSAI_CRASH_ANALYZER @"MSAICrashManager.analyzer"

#define MSAI_METRICS_DATA @"MSAIMetricsManager.plist"
#define MSAI_METRICS_TEMP_DATA @"MSAIMetricsManagerTemp.plist"

#define kMSAIMetaUserName  @"MSAIMetaUserName"
#define kMSAIMetaUserEmail @"MSAIMetaUserEmail"
#define kMSAIMetaUserID    @"MSAIMetaUserID"

#if MSAI_FEATURE_METRICS

extern NSString *const __attribute__((unused)) kMSAIMetricsCachesSessions;
extern NSString *const __attribute__((unused)) kMSAIMetricsTempSessionData;
extern NSString *const __attribute__((unused)) kMSAIMetricsLastAppVersion;

#endif

#define MSAI_INTEGRATIONFLOW_TIMESTAMP  @"MSAIIntegrationFlowStartTimestamp"

#define MSAI_SDK_URL @"https://sdk.hockeyapp.net/"

#define MSAILog(fmt, ...) do { if([MSAITelemetryManager sharedMSAIManager].isDebugLogEnabled && ![MSAITelemetryManager sharedMSAIManager].isAppStoreEnvironment) { NSLog((@"[MSAI] %s/%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }} while(0)

#ifndef __IPHONE_8_0
#define __IPHONE_8_0     80000
#endif

#endif //MSAI_Private_h
