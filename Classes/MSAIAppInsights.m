#import "AppInsights.h"
#import "AppInsightsPrivate.h"
#import "MSAIHelper.h"
#import "MSAIAppClient.h"
#import "MSAIKeychainUtils.h"
#import "MSAIContext.h"
#import "MSAIContextPrivate.h"
#import "MSAIChannel.h"
#import "MSAISender.h"
#import "MSAISenderPrivate.h"
#import "MSAIChannelPrivate.h"
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAIEnvelopeManager.h"
#import "MSAIEnvelopeManagerPrivate.h"
#include <stdint.h>

#if MSAI_FEATURE_CRASH_REPORTER
#import "MSAICrashManager.h"
#import "MSAICrashManagerPrivate.h"
#endif /* MSAI_FEATURE_CRASH_REPORTER */

#if MSAI_FEATURE_METRICS
#import "MSAICategoryContainer.h"
#import "MSAIMetricsManager.h"
#import "MSAIMetricsManagerPrivate.h"
#endif /* MSAI_FEATURE_METRICS */

NSString *const kMSAIInstrumentationKey = @"MSAIInstrumentationKey";

@implementation MSAIAppInsights {
  BOOL _validInstrumentationKey;
  BOOL _startManagerIsInvoked;
  BOOL _managersInitialized;
  MSAIAppClient *_appClient;
  MSAIContext *_appContext;
}

#pragma mark - Shared instance

+ (MSAIAppInsights *)sharedInstance {
  static MSAIAppInsights *sharedInstance = nil;
  static dispatch_once_t pred;
  
  dispatch_once(&pred, ^{
    sharedInstance = [MSAIAppInsights alloc];
    sharedInstance = [sharedInstance init];
  });
  
  return sharedInstance;
}

- (instancetype)init {
  if ((self = [super init])) {
    _serverURL = nil;
    _managersInitialized = NO;
    _appClient = nil;
    _crashManagerDisabled = NO;
    _metricsManagerDisabled = NO;
    _appStoreEnvironment = NO;
    _startManagerIsInvoked = NO;
    
    msai_isAppStoreEnvironment();
    
    [self performSelector:@selector(validateStartManagerIsInvoked) withObject:nil afterDelay:0.0f];
  }
  return self;
}

#pragma mark - Setup & Start

- (void)setup {
  NSString *instrumentationKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:kMSAIInstrumentationKey];
  _appContext = [[MSAIContext alloc] initWithInstrumentationKey:instrumentationKey];
  [self initializeModules];
}

+ (void)setup {
  [[self sharedInstance] setup];
}

- (void)start {
  if (!_validInstrumentationKey) {
    return;
  }
  
  if (_startManagerIsInvoked) {
    NSLog(@"[AppInsights] Warning: start should only be invoked once! This call is ignored.");
    return;
  }
  
  if (![self isSetUpOnMainThread]) {
    return;
  }
  
  MSAILog(@"INFO: Starting MSAIManager");
  _startManagerIsInvoked = YES;
  
  MSAITelemetryContext *telemetryContext = [[MSAITelemetryContext alloc] initWithAppContext:_appContext
                                                                               endpointPath:kMSAITelemetryPath];
  [[MSAIEnvelopeManager sharedManager] configureWithTelemetryContext:telemetryContext];
  [[MSAISender sharedSender] configureWithAppClient:[self appClient]
                                       endpointPath:kMSAITelemetryPath];
  [[MSAISender sharedSender] sendSavedData];
  
#if MSAI_FEATURE_CRASH_REPORTER
  if (![self isCrashManagerDisabled]) {
    MSAILog(@"INFO: Starting MSAICrashManager");
    [MSAICrashManager sharedManager].isCrashManagerDisabled = self.isCrashManagerDisabled;
    [[MSAICrashManager sharedManager] startManager];
  }
#endif /* MSAI_FEATURE_CRASH_REPORTER */
  
#if MSAI_FEATURE_METRICS
  if (![self isMetricsManagerDisabled]) {
    MSAILog(@"INFO: Starting MSAIMetricsManager");
    [[MSAIMetricsManager sharedManager] startManager];
  }
#endif /* MSAI_FEATURE_METRICS */
}

+ (void)start {
  [[self sharedInstance] start];
}

- (void)validateStartManagerIsInvoked {
  if (_validInstrumentationKey && !_appStoreEnvironment) {
    if (!_startManagerIsInvoked) {
      NSLog(@"[AppInsights] ERROR: You did not call [MSAIAppInsights setup] to setup AppInsights! Please do so after setting up all properties. The SDK is NOT running.");
    }
  }
}

- (BOOL)isSetUpOnMainThread {
  NSString *errorString = @"ERROR: AppInsights has to be setup on the main thread!";
  
  if (!NSThread.isMainThread) {
    if (self.isAppStoreEnvironment) {
      MSAILog(@"%@", errorString);
    } else {
      NSLog(@"%@", errorString);
      NSAssert(NSThread.isMainThread, errorString);
    }
    
    return NO;
  }
  
  return YES;
}

- (void)initializeModules {
  if (_managersInitialized) {
    NSLog(@"[AppInsights] Warning: The SDK should only be initialized once! This call is ignored.");
    return;
  }
  
  _validInstrumentationKey = [self checkValidityOfInstrumentationKey:[_appContext instrumentationKey]];
  
  if (![self isSetUpOnMainThread]) return;
  
  _startManagerIsInvoked = NO;
  
  if (_validInstrumentationKey) {
    
#if MSAI_FEATURE_METRICS
    MSAILog(@"INFO: Setup MetricsManager");
    [MSAICategoryContainer activateCategory];
#endif /* MSAI_FEATURE_METRICS */
    
    if (![self isAppStoreEnvironment]) {
      NSString *integrationFlowTime = [self integrationFlowTimeString];
      if (integrationFlowTime && [self integrationFlowStartedWithTimeString:integrationFlowTime]) {
        [self pingServerForIntegrationStartWorkflowWithTimeString:integrationFlowTime instrumentationKey:[_appContext instrumentationKey]];
      }
    }
    _managersInitialized = YES;
  } else {
    if (!_appStoreEnvironment) {
      NSLog(@"[AppInsights] ERROR: The Instrumentation Key is invalid! Please use the AppInsights instrumentation key you find on the website! The SDK is disabled!");
    }
  }
}

#pragma mark - Configuring modules

#if MSAI_FEATURE_METRICS
- (void)setMetricsManagerDisabled:(BOOL)metricsManagerDisabled {
  [MSAIMetricsManager sharedManager].metricsManagerDisabled = metricsManagerDisabled;
  _metricsManagerDisabled = metricsManagerDisabled;
}

+ (void)setMetricsManagerDisabled:(BOOL)metricsManagerDisabled {
  [[self sharedInstance] setMetricsManagerDisabled:metricsManagerDisabled];
}
#endif /* MSAI_FEATURE_METRICS */


#if MSAI_FEATURE_CRASH_REPORTER
- (void)setCrashManagerDisabled:(BOOL)crashManagerDisabled {
  [MSAICrashManager sharedManager].isCrashManagerDisabled = crashManagerDisabled;
  _crashManagerDisabled = crashManagerDisabled;
}

+ (void)setCrashManagerDisabled:(BOOL)crashManagerDisabled{
  [[self sharedInstance] setCrashManagerDisabled:crashManagerDisabled];
}
#endif /* MSAI_FEATURE_CRASH_REPORTER */

- (void)setServerURL:(NSString *)serverURL {
  
  // trailing slash is needed
  if (![serverURL hasSuffix:@"/"]) {
    serverURL = [NSString stringWithFormat:@"%@/", serverURL];
  }
  
  if (_serverURL != serverURL) {
    _serverURL = [serverURL copy];
    
    if (_appClient) {
      self.appClient.baseURL = [NSURL URLWithString:_serverURL ? _serverURL : MSAI_SDK_URL];
    }
  }
}

+ (void)setServerURL:(NSString *)serverURL {
  [[self sharedInstance] setServerURL:serverURL];
}

#pragma mark - Testing integration

- (void)testIdentifier {
  if (![_appContext instrumentationKey] || msai_isAppStoreEnvironment()) {
    return;
  }
  
  NSDate *now = [NSDate date];
  NSString *timeString = [NSString stringWithFormat:@"%.0f", [now timeIntervalSince1970]];
  [self pingServerForIntegrationStartWorkflowWithTimeString:timeString
                                         instrumentationKey:[_appContext instrumentationKey]];
}

+ (void)testIdentifier {
  [[self sharedInstance] testIdentifier];
}

- (NSString *)integrationFlowTimeString {
  NSString *timeString = [[NSBundle mainBundle] objectForInfoDictionaryKey:kMSAIIntegrationflowTimestamp];
  
  return timeString;
}

- (BOOL)integrationFlowStartedWithTimeString:(NSString *)timeString {
  if (timeString == nil || [self isAppStoreEnvironment]) {
    return NO;
  }
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  [dateFormatter setLocale:enUSPOSIXLocale];
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
  NSDate *integrationFlowStartDate = [dateFormatter dateFromString:timeString];
  
  if (integrationFlowStartDate && [integrationFlowStartDate timeIntervalSince1970] > [[NSDate date] timeIntervalSince1970] - (60 * 10) ) {
    return YES;
  }
  
  return NO;
}

- (void)pingServerForIntegrationStartWorkflowWithTimeString:(NSString *)timeString instrumentationKey:(NSString *)instrumentationKey {
  if (!instrumentationKey || [self isAppStoreEnvironment]) {
    return;
  }
  
  NSString *integrationPath = [NSString stringWithFormat:@"api/3/apps/%@/integration", msai_encodeInstrumentationKey(instrumentationKey)];
  
  MSAILog(@"INFO: Sending integration workflow ping to %@", integrationPath);
  
  [[self appClient] postPath:integrationPath
                  parameters:@{@"timestamp": timeString,
                               @"sdk": kMSAIName,
                               @"sdk_version": MSAI_VERSION,
                               @"bundle_version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
                               }
                  completion:^(MSAIHTTPOperation *operation, NSData* responseData, NSError *error) {
                    switch (operation.response.statusCode) {
                      case 400:
                        MSAILog(@"ERROR: App ID not found");
                        break;
                      case 201:
                        MSAILog(@"INFO: Ping accepted.");
                        break;
                      case 200:
                        MSAILog(@"INFO: Ping accepted. Server already knows.");
                        break;
                      default:
                        MSAILog(@"ERROR: Unknown error");
                        break;
                    }
                  }];
}

#pragma mark - Meta data

- (NSString *)version {
  return msai_sdkVersion();
}

+ (NSString *)version {
  return [[self sharedInstance] version];
}

- (NSString *)build {
  return msai_sdkBuild();
}

+ (NSString *)build {
  return [[self sharedInstance] build];
}

#pragma mark - Helper

- (BOOL)checkValidityOfInstrumentationKey:(NSString *)instrumentationKey {
  BOOL result = NO;
  
  if (instrumentationKey) {
    NSCharacterSet *hexSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdef-"];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:instrumentationKey];
    result = ([instrumentationKey length] == 36) && ([hexSet isSupersetOfSet:inStringSet]);
  }
  
  return result;
}

- (MSAIAppClient *)appClient {
  if (!_appClient) {
    _appClient = [[MSAIAppClient alloc] initWithBaseURL:[NSURL URLWithString:_serverURL ? _serverURL : MSAI_SDK_URL]];
    
    _appClient.baseURL = [NSURL URLWithString:_serverURL ? _serverURL : MSAI_SDK_URL];
  }
  
  return _appClient;
}

@end
