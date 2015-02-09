#import "AppInsights.h"
#import "AppInsightsPrivate.h"

#import "MSAIBaseManagerPrivate.h"
#import "MSAIHelper.h"
#import "MSAIAppClient.h"
#import "MSAIKeychainUtils.h"
#import "MSAIContext.h"
#import "MSAIContextPrivate.h"
#import "MSAICategoryContainer.h"
#import "MSAIChannel.h"
#import "MSAIChannelPrivate.h"
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#include <stdint.h>


#if MSAI_FEATURE_CRASH_REPORTER
#import "MSAICrashManagerPrivate.h"
#endif /* MSAI_FEATURE_CRASH_REPORTER */

#if MSAI_FEATURE_METRICS
#import "MSAIMetricsManagerPrivate.h"
#endif /* MSAI_FEATURE_METRICS */


@implementation MSAITelemetryManager {
  
  BOOL _validInstrumentationKey;
  
  BOOL _startManagerIsInvoked;
  
  BOOL _startUpdateManagerIsInvoked;
  
  BOOL _managersInitialized;
  
  MSAIAppClient *_appClient;
  
  MSAIContext *_appContext;
}

#pragma mark - Private Class Methods

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
    NSLog(@"[AppInsightsSDK] ERROR: The %@ is invalid! Please use the AppInsights app identifier you find on the apps website on AppInsights! The SDK is disabled!", environment);
  }
}


#pragma mark - Public Class Methods

+ (MSAITelemetryManager *)sharedMSAIManager {
  static MSAITelemetryManager *sharedInstance = nil;
  static dispatch_once_t pred;
  
  dispatch_once(&pred, ^{
    sharedInstance = [MSAITelemetryManager alloc];
    sharedInstance = [sharedInstance init];
  });
  
  return sharedInstance;
}

- (id) init {
  if ((self = [super init])) {
    _serverURL = nil;
    _delegate = nil;
    _managersInitialized = NO;
    
    _appClient = nil;
    
    _disableCrashManager = NO;
    _disableMetricsManager = NO;
    
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


#pragma mark - Public Instance Methods (Configuration)

- (void)configureWithInstrumentationKey:(NSString *)instrumentationKey {
  
  _appContext = [[MSAIContext alloc] initWithInstrumentationKey:instrumentationKey isAppStoreEnvironment:_appStoreEnvironment];
  
  [self initializeModules];
}

- (void)configureWithInstrumentationKey:(NSString *)instrumentationKey delegate:(id <MSAITelemetryManagerDelegate>)delegate {
  _delegate = delegate;
  _appContext = [[MSAIContext alloc] initWithInstrumentationKey:instrumentationKey isAppStoreEnvironment:_appStoreEnvironment];
  
  [self initializeModules];
}

- (void)startManager {
  if (!_validInstrumentationKey) return;
  if (_startManagerIsInvoked) {
    NSLog(@"[AppInsightsSDK] Warning: startManager should only be invoked once! This call is ignored.");
    return;
  }
  
  if (![self isSetUpOnMainThread]) return;
  
  MSAILog(@"INFO: Starting MSAITelemetryManager");
  _startManagerIsInvoked = YES;
  
  [[MSAIChannel sharedChannel]configureWithAppClient:[self appClient] telemetryContext: [self telemetryContext]];
#if MSAI_FEATURE_CRASH_REPORTER
  // start CrashManager
  if (![self isCrashManagerDisabled]) {
    MSAILog(@"INFO: Start CrashManager");
    [_crashManager startManager];
  }
#endif /* MSAI_FEATURE_CRASH_REPORTER */
  
#if MSAI_FEATURE_METRICS
  if (![self isMetricsManagerDisabled]) {
    MSAILog(@"INFO: Start MetricsManager");
    [MSAIMetricsManager startManager];
  }
#endif /* MSAI_FEATURE_METRICS */
  
  // App Extensions can only use MSAICrashManager, so ignore all others automatically
  if (msai_isRunningInAppExtension()) {
    return;
  }
}

#if MSAI_FEATURE_METRICS
- (void)setDisableMetricsManager:(BOOL)disableMetricsManager {
  [MSAIMetricsManager setDisableMetricsManager:disableMetricsManager];
  _disableMetricsManager = disableMetricsManager;
}
#endif /* MSAI_FEATURE_METRICS */


- (void)setServerURL:(NSString *)aServerURL {
  // ensure url ends with a trailing slash
  if (![aServerURL hasSuffix:@"/"]) {
    aServerURL = [NSString stringWithFormat:@"%@/", aServerURL];
  }
  
  if (_serverURL != aServerURL) {
    _serverURL = [aServerURL copy];
    
    if (_appClient) {
      _appClient.baseURL = [NSURL URLWithString:_serverURL ? _serverURL : MSAI_SDK_URL];
    }
  }
}


- (void)setDelegate:(id<MSAITelemetryManagerDelegate>)delegate {
  if (![self isAppStoreEnvironment]) {
    if (_startManagerIsInvoked) {
      NSLog(@"[MSAI] ERROR: The `delegate` property has to be set before calling [[MSAITelemetryManager sharedManager] startManager] !");
    }
  }
  
  if (_delegate != delegate) {
    _delegate = delegate;
    
#if MSAI_FEATURE_CRASH_REPORTER
    if (_crashManager) {
      _crashManager.delegate = _delegate;
    }
#endif /* MSAI_FEATURE_CRASH_REPORTER */
  }
}

- (void)modifyKeychainUserValue:(NSString *)value forKey:(NSString *)key {
  NSError *error = nil;
  BOOL success = YES;
  NSString *updateType = @"update";
  
  if (value) {
    success = [MSAIKeychainUtils storeUsername:key
                                   andPassword:value
                                forServiceName:msai_keychainMSAIServiceName()
                                updateExisting:YES
                                 accessibility:kSecAttrAccessibleWhenUnlockedThisDeviceOnly
                                         error:&error];
  } else {
    updateType = @"delete";
    if ([MSAIKeychainUtils getPasswordForUsername:key
                                   andServiceName:msai_keychainMSAIServiceName()
                                            error:&error]) {
      success = [MSAIKeychainUtils deleteItemForUsername:key
                                          andServiceName:msai_keychainMSAIServiceName()
                                                   error:&error];
    }
  }
  
  if (!success) {
    NSString *errorDescription = [error description] ?: @"";
    MSAILog(@"ERROR: Couldn't %@ key %@ in the keychain. %@", updateType, key, errorDescription);
  }
}

- (void)setUserID:(NSString *)userID {
  // always set it, since nil value will trigger removal of the keychain entry
  _userID = userID;
  
  [self modifyKeychainUserValue:userID forKey:kMSAIMetaUserID];
}

- (void)setUserName:(NSString *)userName {
  // always set it, since nil value will trigger removal of the keychain entry
  _userName = userName;
  
  [self modifyKeychainUserValue:userName forKey:kMSAIMetaUserName];
}

- (void)setUserEmail:(NSString *)userEmail {
  // always set it, since nil value will trigger removal of the keychain entry
  _userEmail = userEmail;
  
  [self modifyKeychainUserValue:userEmail forKey:kMSAIMetaUserEmail];
}

- (void)testIdentifier {
  if (![_appContext instrumentationKey] || [_appContext isAppStoreEnvironment]) {
    return;
  }
  
  NSDate *now = [NSDate date];
  NSString *timeString = [NSString stringWithFormat:@"%.0f", [now timeIntervalSince1970]];
  [self pingServerForIntegrationStartWorkflowWithTimeString:timeString instrumentationKey:[_appContext instrumentationKey]];
}


- (NSString *)version {
  return msai_sdkVersion();
}

- (NSString *)build {
  return msai_sdkBuild();
}


#pragma mark - Private Instance Methods

- (MSAITelemetryContext *)telemetryContext{
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
      NSLog(@"[AppInsightsSDK] ERROR: You did not call [[MSAITelemetryManager sharedManager] startManager] to startup the AppInsightsSDK! Please do so after setting up all properties. The SDK is NOT running.");
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
    
#if MSAI_FEATURE_CRASH_REPORTER
    MSAILog(@"INFO: Setup CrashManager");
    _crashManager = [[MSAICrashManager alloc]initWithAppContext:_appContext];
    _crashManager.delegate = _delegate;
#endif /* MSAI_FEATURE_CRASH_REPORTER */
    
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
    [self logInvalidIdentifier:@"app identifier"];
  }
}

@end
