#import "AppInsights.h"
#import "AppInsightsPrivate.h"

#import "MSAIHelper.h"
#import "MSAIAppClient.h"
#import "MSAIKeychainUtils.h"
#import "MSAIContext.h"
#import "MSAIContextPrivate.h"
#import "MSAICategoryContainer.h"
#import "MSAIChannel.h"
#import "MSAISender.h"
#import "MSAISenderPrivate.h"
#import "MSAIChannelPrivate.h"
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAIEnvelopeManager.h"
#import "MSAIEnvelopeManagerPrivate.h"
#include <stdint.h>
#import "MSAICrashManager.h"


#if MSAI_FEATURE_CRASH_REPORTER
#import "MSAICrashManagerPrivate.h"
#endif /* MSAI_FEATURE_CRASH_REPORTER */

#if MSAI_FEATURE_METRICS
#import "MSAIMetricsManagerPrivate.h"
#endif /* MSAI_FEATURE_METRICS */

NSString *const kMSAIInstrumentationKey = @"MSAIInstrumentationKey";

@implementation MSAIAppInsights {
  
  BOOL _validInstrumentationKey;
  BOOL _startManagerIsInvoked;
  BOOL _startUpdateManagerIsInvoked;
  BOOL _managersInitialized;
  MSAIAppClient *_appClient;
  MSAIContext *_appContext;
  MSAITelemetryContext *_telemetryContext;
}

#pragma mark - Public Class Methods

+ (MSAIAppInsights *)sharedInstance {
  static MSAIAppInsights *sharedInstance = nil;
  static dispatch_once_t pred;
  
  dispatch_once(&pred, ^{
    sharedInstance = [MSAIAppInsights alloc];
    sharedInstance = [sharedInstance init];
  });
  
  return sharedInstance;
}

#pragma mark - Init

- (id) init {
  if ((self = [super init])) {
    _serverURL = nil;
    _managersInitialized = NO;
    _appClient = nil;
    _crashManagerDisabled = NO;
    _metricsManagerDisabled = NO;
    _appStoreEnvironment = NO;
    _startManagerIsInvoked = NO;
    _startUpdateManagerIsInvoked = NO;
    _installString = msai_appAnonID();
    
#if !TARGET_IPHONE_SIMULATOR
    // check if we are really in an app store environment
    if (![[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"]) {
      _appStoreEnvironment = YES;
    }
#endif
    
    [self performSelector:@selector(validateStartManagerIsInvoked) withObject:nil afterDelay:0.0f];
    
  }
  return self;
}

#pragma mark - Public Methods

- (void)setup {
  NSString *iKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:kMSAIInstrumentationKey];
  _appContext = [[MSAIContext alloc] initWithInstrumentationKey:iKey isAppStoreEnvironment:_appStoreEnvironment];
  [self initializeModules];
}

+ (void)setup {
    [[self sharedInstance] setup];
}

- (void)start {
  if (!_validInstrumentationKey) return;
  if (_startManagerIsInvoked) {
    NSLog(@"[AppInsightsSDK] Warning: start should only be invoked once! This call is ignored.");
    return;
  }
  
  if (![self isSetUpOnMainThread]) return;
  
  MSAILog(@"INFO: Starting MSAIManager");
  _startManagerIsInvoked = YES;
  
  [[MSAIEnvelopeManager sharedManager] configureWithTelemetryContext:[self telemetryContext]];
  [[MSAISender sharedSender] configureWithAppClient:[self appClient] endpointPath:[[self telemetryContext] endpointPath]];
  [[MSAISender sharedSender] sendSavedData];
#if MSAI_FEATURE_CRASH_REPORTER
  // start CrashManager
  if (![self isCrashManagerDisabled]) {
    MSAILog(@"INFO: Starting MSAICrashManager");
    [MSAICrashManager sharedManager].isCrashManagerDisabled = self.isCrashManagerDisabled;
      //this will init the crash manager
      //if we haven't set the crashManagerStatus it won't do anything!!!
    [MSAICrashManager startWithContext:_appContext];
  }
#endif /* MSAI_FEATURE_CRASH_REPORTER */
  
#if MSAI_FEATURE_METRICS
  if (![self isMetricsManagerDisabled]) {
    MSAILog(@"INFO: Starting MSAIMetricsManager");
    [[MSAIMetricsManager sharedManager] startManager];
  }
#endif /* MSAI_FEATURE_METRICS */
  
  // App Extensions can only use MSAICrashManager, so ignore all others automatically
  if (msai_isRunningInAppExtension()) {
    return;
  }
}

+ (void)start {
  [[self sharedInstance] start];
}

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

#endif

- (void)setServerURL:(NSString *)serverURL {
  // ensure url ends with a trailing slash
  if (![serverURL hasSuffix:@"/"]) {
    serverURL = [NSString stringWithFormat:@"%@/", serverURL];
  }
  
  if (_serverURL != serverURL) {
    _serverURL = [serverURL copy];
    
    if (_appClient) {
      _appClient.baseURL = [NSURL URLWithString:_serverURL ? _serverURL : MSAI_SDK_URL];
    }
  }
}

+ (void)setServerURL:(NSString *)serverURL {
  [[self sharedInstance] setServerURL:serverURL];
}

- (void)testIdentifier {
  if (![_appContext instrumentationKey] || [_appContext isAppStoreEnvironment]) {
    return;
  }
  
  NSDate *now = [NSDate date];
  NSString *timeString = [NSString stringWithFormat:@"%.0f", [now timeIntervalSince1970]];
  [self pingServerForIntegrationStartWorkflowWithTimeString:timeString instrumentationKey:[_appContext instrumentationKey]];
}

+ (void)testIdentifier {
  [[self sharedInstance] testIdentifier];
}

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

#pragma mark - Private Instance Methods

- (BOOL)checkValidityOfInstrumentationKey:(NSString *)instrumentationKey {
  BOOL result = NO;
  
  if (instrumentationKey) {
    NSCharacterSet *hexSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdef-"];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:instrumentationKey];
    result = ([instrumentationKey length] == 36) && ([hexSet isSupersetOfSet:inStringSet]);
  }
  
  return result;
}

- (void)logInvalidIdentifier:(NSString *)environment {
  if (!_appStoreEnvironment) {
    NSLog(@"[AppInsightsSDK] ERROR: The %@ is invalid! Please use the AppInsights instrumentation key you find on the website! The SDK is disabled!", environment);
  }
}

- (MSAITelemetryContext *)telemetryContext{
  
  if(_telemetryContext){
    return _telemetryContext;
  }
  
  MSAIDevice *deviceContext = [MSAIDevice new];
  [deviceContext setModel: [_appContext deviceModel]];
  [deviceContext setType:[_appContext deviceType]];
  [deviceContext setOsVersion:[_appContext osVersion]];
  [deviceContext setOs:[_appContext osName]];
  [deviceContext setDeviceId:msai_appAnonID()];
  deviceContext.locale = msai_deviceLocale();
  deviceContext.language = msai_deviceLanguage();
  [deviceContext setOemName:@"Apple"];
  deviceContext.screenResolution = msai_screenSize();
  
  MSAIInternal *internalContext = [MSAIInternal new];
  [internalContext setSdkVersion: msai_sdkVersion()];
  
  MSAIApplication *applicationContext = [MSAIApplication new];
  [applicationContext setVersion:[_appContext appVersion]];
  
  MSAISession *sessionContext = [MSAISession new];
  
  MSAIOperation *operationContext = [MSAIOperation new];
  MSAIUser *userContext = [MSAIUser new];
  MSAILocation *locationContext = [MSAILocation new];
  
  //TODO: Add additional context data
  MSAITelemetryContext *telemetryContext = [[MSAITelemetryContext alloc]initWithInstrumentationKey:[_appContext instrumentationKey]
                                                                                      endpointPath:MSAI_TELEMETRY_PATH
                                                                                applicationContext:applicationContext
                                                                                     deviceContext:deviceContext
                                                                                   locationContext:locationContext
                                                                                    sessionContext:sessionContext
                                                                                       userContext:userContext
                                                                                   internalContext:internalContext
                                                                                  operationContext:operationContext];
  return telemetryContext;
}

- (MSAIAppClient *)appClient {
  if (!_appClient) {
    _appClient = [[MSAIAppClient alloc] initWithBaseURL:[NSURL URLWithString:_serverURL ? _serverURL : MSAI_SDK_URL]];
    
    _appClient.baseURL = [NSURL URLWithString:_serverURL ? _serverURL : MSAI_SDK_URL];
  }
  
  return _appClient;
}

- (NSString *)integrationFlowTimeString {
  NSString *timeString = [[NSBundle mainBundle] objectForInfoDictionaryKey:MSAI_INTEGRATIONFLOW_TIMESTAMP];
  
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
                               @"sdk": MSAI_NAME,
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

- (void)validateStartManagerIsInvoked {
  if (_validInstrumentationKey && !_appStoreEnvironment) {
    if (!_startManagerIsInvoked) {
      NSLog(@"[AppInsightsSDK] ERROR: You did not call [MSAIAppInsights setup] to setup the AppInsightsSDK! Please do so after setting up all properties. The SDK is NOT running.");
    }
  }
}

- (BOOL)isSetUpOnMainThread {
  NSString *errorString = @"ERROR: AppInsightsSDK has to be setup on the main thread!";
  
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
    NSLog(@"[AppInsightsSDK] Warning: The SDK should only be initialized once! This call is ignored.");
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
    [self logInvalidIdentifier:@"instrumentation key"];
  }
}

@end
