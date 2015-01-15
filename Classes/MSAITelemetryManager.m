#import "AppInsights.h"
#import "AppInsightsPrivate.h"

#import "MSAIBaseManagerPrivate.h"

#import "MSAIHelper.h"
#import "MSAIAppClient.h"
#import "MSAIKeychainUtils.h"

#include <stdint.h>

typedef struct {
  uint8_t       info_version;
  const char    msai_version[16];
  const char    msai_build[16];
} msai_info_t;

msai_info_t applicationinsights_library_info __attribute__((section("__TEXT,__msai_ios,regular,no_dead_strip"))) = {
  .info_version = 1,
  .msai_version = MSAI_C_VERSION,
  .msai_build = MSAI_C_BUILD
};


#if MSAI_FEATURE_CRASH_REPORTER
#import "MSAICrashManagerPrivate.h"
#endif /* MSAI_FEATURE_CRASH_REPORTER */

#if MSAI_FEATURE_METRICS
#import "MSAIMetricsManagerPrivate.h"
#endif /* MSAI_FEATURE_METRICS */


@implementation MSAITelemetryManager {
  NSString *_appIdentifier;
  
  BOOL _validAppIdentifier;
  
  BOOL _startManagerIsInvoked;
  
  BOOL _startUpdateManagerIsInvoked;
  
  BOOL _managersInitialized;
  
  MSAIAppClient *_appClient;
}

#pragma mark - Private Class Methods

- (BOOL)checkValidityOfAppIdentifier:(NSString *)identifier {
  BOOL result = NO;
  
  if (identifier) {
    NSCharacterSet *hexSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdef"];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:identifier];
    result = ([identifier length] == 32) && ([hexSet isSupersetOfSet:inStringSet]);
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

- (void)configureWithIdentifier:(NSString *)appIdentifier {
  _appIdentifier = [appIdentifier copy];
  
  [self initializeModules];
}

- (void)configureWithIdentifier:(NSString *)appIdentifier delegate:(id)delegate {
  _delegate = delegate;
  _appIdentifier = [appIdentifier copy];
  
  [self initializeModules];
}

- (void)startManager {
  if (!_validAppIdentifier) return;
  if (_startManagerIsInvoked) {
    NSLog(@"[AppInsightsSDK] Warning: startManager should only be invoked once! This call is ignored.");
    return;
  }
  
  if (![self isSetUpOnMainThread]) return;
  
  MSAILog(@"INFO: Starting MSAITelemetryManager");
  _startManagerIsInvoked = YES;
  
#if MSAI_FEATURE_CRASH_REPORTER
  // start CrashManager
  if (![self isCrashManagerDisabled]) {
    MSAILog(@"INFO: Start CrashManager");
    if (_serverURL) {
      [_crashManager setServerURL:_serverURL];
    }
    
    [_crashManager startManager];
  }
#endif /* MSAI_FEATURE_CRASH_REPORTER */
  
  // App Extensions can only use MSAICrashManager, so ignore all others automatically
  if (msai_isRunningInAppExtension()) {
    return;
  }

#if MSAI_FEATURE_METRICS
  if (_metricsManager && ![self isMetricsManagerDisabled]) {
    [_metricsManager startManager];
  }
#endif /* MSAI_FEATURE_METRICS */
}


#if MSAI_FEATURE_METRICS
- (void)setDisableMetricsManager:(BOOL)disableMetricsManager {
  if (_metricsManager) {
    [_metricsManager setDisableMetricsManager:disableMetricsManager];
  }
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
  if (!_appIdentifier || [self isAppStoreEnvironment]) {
    return;
  }
  
  NSDate *now = [NSDate date];
  NSString *timeString = [NSString stringWithFormat:@"%.0f", [now timeIntervalSince1970]];
  [self pingServerForIntegrationStartWorkflowWithTimeString:timeString appIdentifier:_appIdentifier];
}


- (NSString *)version {
  return [NSString stringWithUTF8String:applicationinsights_library_info.msai_version];
}

- (NSString *)build {
  return [NSString stringWithUTF8String:applicationinsights_library_info.msai_build];
}


#pragma mark - Private Instance Methods

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

- (void)pingServerForIntegrationStartWorkflowWithTimeString:(NSString *)timeString appIdentifier:(NSString *)appIdentifier {
  if (!appIdentifier || [self isAppStoreEnvironment]) {
    return;
  }
  
  NSString *integrationPath = [NSString stringWithFormat:@"api/3/apps/%@/integration", msai_encodeAppIdentifier(appIdentifier)];
  
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
  if (_validAppIdentifier && !_appStoreEnvironment) {
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
  
  _validAppIdentifier = [self checkValidityOfAppIdentifier:_appIdentifier];
  
  if (![self isSetUpOnMainThread]) return;
  
  _startManagerIsInvoked = NO;
  
  if (_validAppIdentifier) {
#if MSAI_FEATURE_CRASH_REPORTER
    MSAILog(@"INFO: Setup CrashManager");
    _crashManager = [[MSAICrashManager alloc] initWithAppIdentifier:_appIdentifier isAppStoreEnvironment:_appStoreEnvironment];
    _crashManager.appClient = [self appClient];
    _crashManager.delegate = _delegate;
#endif /* MSAI_FEATURE_CRASH_REPORTER */
    
#if MSAI_FEATURE_METRICS
    MSAILog(@"INFO: Setup MetricsManager");
    _metricsManager = [[MSAIMetricsManager alloc] initWithAppIdentifier:_appIdentifier appClient:_appClient isAppStoreEnvironment:_appStoreEnvironment];
#endif /* MSAI_FEATURE_METRICS */

    if (![self isAppStoreEnvironment]) {
      NSString *integrationFlowTime = [self integrationFlowTimeString];
      if (integrationFlowTime && [self integrationFlowStartedWithTimeString:integrationFlowTime]) {
        [self pingServerForIntegrationStartWorkflowWithTimeString:integrationFlowTime appIdentifier:_appIdentifier];
      }
    }
    _managersInitialized = YES;
  } else {
    [self logInvalidIdentifier:@"app identifier"];
  }
}

@end
