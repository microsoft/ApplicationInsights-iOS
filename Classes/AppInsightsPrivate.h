#import <Foundation/Foundation.h>

#ifndef MSAI_Private_h
#define MSAI_Private_h

#define MSAI_NAME @"AppInsights"
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

//#define MSAI_SDK_URL          @"https://dc.services.visualstudio.com/"
#define MSAI_CRASH_DATA_URL          @"https://deathray-int.trafficmanager.net/v2/track"
#define MSAI_EVENT_DATA_URL       @"https://dc-int.services.visualstudio.com/v2/track"
#define MSAI_SDK_URL              MSAI_EVENT_DATA_URL
#define MSAI_TELEMETRY_PATH   @"v2/track"

#define MSAILog(fmt, ...) do { if([MSAIManager sharedMSAIManager].isDebugLogEnabled && ![MSAIManager sharedMSAIManager].isAppStoreEnvironment) { NSLog((@"[MSAI] %s/%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }} while(0)

#ifndef __IPHONE_8_0
#define __IPHONE_8_0     80000
#endif

#endif //MSAI_Private_h
