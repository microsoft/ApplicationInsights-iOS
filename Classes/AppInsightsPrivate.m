#import "AppInsights.h"
#import "AppInsightsPrivate.h"

NSString *const kMSAIName = @"AppInsights";
NSString *const kMSAIIdentifier = @"com.microsoft.applicationinsights.ios";
NSString *const kMSAICrashSettings = @"MSAICrashManager.plist";
NSString *const kMSAICrashAnalyzer = @"MSAICrashManager.analyzer";

NSString *const kMSAICrashErrorDomain = @"MSAICrashReporterErrorDomain";
NSString *const kMSAIErrorDomain = @"MSAIErrorDomain";

NSString *const kMSAIIntegrationflowTimestamp = @"MSAIIntegrationFlowStartTimestamp";

NSString *const kMSAITelemetryPath = @"v2/track";
