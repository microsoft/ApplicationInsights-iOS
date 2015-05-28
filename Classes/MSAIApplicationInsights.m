#import "ApplicationInsights.h"
#import "ApplicationInsightsPrivate.h"
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
#import "MSAIContextHelper.h"
#import "MSAIContextHelperPrivate.h"
#include <stdint.h>

#if MSAI_FEATURE_CRASH_REPORTER
#import "MSAICrashManager.h"
#import "MSAICrashManagerPrivate.h"
#endif /* MSAI_FEATURE_CRASH_REPORTER */

#if MSAI_FEATURE_TELEMETRY
#import "MSAICategoryContainer.h"
#import "MSAITelemetryManager.h"
#import "MSAITelemetryManagerPrivate.h"
#endif /* MSAI_FEATURE_TELEMETRY */

NSString *const kMSAIInstrumentationKey = @"MSAIInstrumentationKey";

@implementation MSAIApplicationInsights {
  BOOL _validInstrumentationKey;
  BOOL _startManagerIsInvoked;
  BOOL _managersInitialized;
  MSAIAppClient *_appClient;
  MSAIContext *_appContext;
}

#pragma mark - Shared instance

+ (MSAIApplicationInsights *)sharedInstance {
  static MSAIApplicationInsights *sharedInstance = nil;
  static dispatch_once_t pred;
  
  dispatch_once(&pred, ^{
    sharedInstance = [MSAIApplicationInsights alloc];
    sharedInstance = [sharedInstance init];
  });
  
  return sharedInstance;
}

- (instancetype)init {
  if ((self = [super init])) {
    _serverURL = nil;
    _managersInitialized = NO;
    _appClient = nil;
#if MSAI_FEATURE_CRASH_REPORTER
    _crashManagerDisabled = NO;
#endif /* MSAI_FEATURE_CRASH_REPORTER */
#if MSAI_FEATURE_TELEMETRY
    _telemetryManagerDisabled = NO;
#endif /* MSAI_FEATURE_TELEMETRY */
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
  [self setupWithInstrumentationKey:instrumentationKey];
}

- (void)setupWithInstrumentationKey:(NSString *)instrumentationKey{
  _appContext = [[MSAIContext alloc] initWithInstrumentationKey:instrumentationKey];
  [self initializeModules];
}

+ (void)setup {
  [[self sharedInstance] setup];
}

+ (void)setupWithInstrumentationKey:(NSString *)instrumentationKey{
  [[self sharedInstance] setupWithInstrumentationKey:instrumentationKey];
}

- (void)start {
  if (!_validInstrumentationKey) {
    return;
  }
  
  if (_startManagerIsInvoked) {
    NSLog(@"[ApplicationInsights] Warning: start should only be invoked once! This call is ignored.");
    return;
  }
  
  if (![self isSetUpOnMainThread]) {
    return;
  }
  
  MSAILog(@"INFO: Starting MSAIManager");
  _startManagerIsInvoked = YES;
  
  [[MSAISender sharedSender] sendSavedData];
  
#if MSAI_FEATURE_CRASH_REPORTER
  if (![self isCrashManagerDisabled]) {
    MSAILog(@"INFO: Starting MSAICrashManager");
    [MSAICrashManager sharedManager].isCrashManagerDisabled = self.isCrashManagerDisabled;
    [[MSAICrashManager sharedManager] startManager];
  }
#endif /* MSAI_FEATURE_CRASH_REPORTER */
  
#if MSAI_FEATURE_TELEMETRY
  if (![self isTelemetryManagerDisabled]) {
    
    if([self isAutoPageViewTrackingDisabled]){
      MSAILog(@"INFO: Auto page views disabled");
      [MSAITelemetryManager sharedManager].autoPageViewTrackingDisabled = YES;
    }
    [MSAICategoryContainer activateCategory];
    
    MSAILog(@"INFO: Starting MSAITelemetryManager");
    [[MSAITelemetryManager sharedManager] startManager];
  }
#endif /* MSAI_FEATURE_TELEMETRY */
}

+ (void)start {
  [[self sharedInstance] start];
}

- (void)validateStartManagerIsInvoked {
  if (_validInstrumentationKey && !_appStoreEnvironment) {
    if (!_startManagerIsInvoked) {
      NSLog(@"[ApplicationInsights] ERROR: You did not call [MSAIApplicationInsights setup] to setup ApplicationInsights! Please do so after setting up all properties. The SDK is NOT running.");
    }
  }
}

- (BOOL)isSetUpOnMainThread {
  NSString *errorString = @"[ApplicationInsights] ERROR: ApplicationInsights has to be setup on the main thread!";
  
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
    NSLog(@"[ApplicationInsights] Warning: The SDK should only be initialized once! This call is ignored.");
    return;
  }
  
  _validInstrumentationKey = [self checkValidityOfInstrumentationKey:[_appContext instrumentationKey]];
  
  if (![self isSetUpOnMainThread]) return;
  
  _startManagerIsInvoked = NO;
  
  if (_validInstrumentationKey) {
    // Configure Http-client and send persisted data
    
    MSAITelemetryContext *telemetryContext = [[MSAITelemetryContext alloc] initWithAppContext:_appContext];
    [[MSAIEnvelopeManager sharedManager] configureWithTelemetryContext:telemetryContext];
    
    [[MSAISender sharedSender] configureWithAppClient:[self appClient]];
    
#if MSAI_FEATURE_TELEMETRY
    MSAILog(@"INFO: Setup TelemetryManager");
#endif /* MSAI_FEATURE_TELEMETRY */
    
    _managersInitialized = YES;
  } else {
    if (!_appStoreEnvironment) {
      NSLog(@"[ApplicationInsights] ERROR: The Instrumentation Key is invalid! Please use the Application Insights instrumentation key you find on the website! The SDK is disabled!");
    }
  }
}

#pragma mark - Configuring modules
#if MSAI_FEATURE_TELEMETRY
- (void)setTelemetryManagerDisabled:(BOOL)telemetryManagerDisabled {
  [MSAITelemetryManager sharedManager].telemetryManagerDisabled = telemetryManagerDisabled;
  _telemetryManagerDisabled = telemetryManagerDisabled;
}

+ (void)setTelemetryManagerDisabled:(BOOL)telemetryManagerDisabled {
  [[self sharedInstance] setTelemetryManagerDisabled:telemetryManagerDisabled];
}

- (void)setAutoPageViewTrackingDisabled:(BOOL)autoPageViewTrackingDisabled {
  [MSAITelemetryManager sharedManager].autoPageViewTrackingDisabled = autoPageViewTrackingDisabled;
  _autoPageViewTrackingDisabled = autoPageViewTrackingDisabled;
}

+ (void)setAutoPageViewTrackingDisabled:(BOOL)autoPageViewTrackingDisabled {
  [[self sharedInstance] setAutoPageViewTrackingDisabled:autoPageViewTrackingDisabled];
}

- (void)setAutoSessionManagementDisabled:(BOOL)autoSessionManagementDisabled {
  [MSAIContextHelper sharedInstance].autoSessionManagementDisabled = autoSessionManagementDisabled;
  [[MSAIContextHelper sharedInstance] unregisterObservers];
  _autoSessionManagementDisabled = autoSessionManagementDisabled;

}
+ (void)setAutoSessionManagementDisabled:(BOOL)autoSessionManagementDisabled {
  [[self sharedInstance] setAutoSessionManagementDisabled:autoSessionManagementDisabled];
}

#endif /* MSAI_FEATURE_TELEMETRY */

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
      self.appClient.baseURL = [NSURL URLWithString:_serverURL ? _serverURL : MSAI_SERVER_URL];
    }
  }
}

+ (void)setServerURL:(NSString *)serverURL {
  [[self sharedInstance] setServerURL:serverURL];
}

#pragma mark - SDK meta data

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

#pragma mark - Context meta data

+ (void)setUserId:(NSString *)userId {
  [[self sharedInstance] setUserId:userId];
}

- (void)setUserId:(NSString *)userId {
  [[MSAIContextHelper sharedInstance] setCurrentUserId:userId];
}

+ (void)startNewSession {
  [[self sharedInstance] startNewSession];
}

- (void)startNewSession {
  [[MSAIContextHelper sharedInstance] startNewSession];
}

+ (void)setAppBackgroundTimeBeforeSessionExpires:(NSUInteger)appBackgroundTimeBeforeSessionExpires {
  [[self sharedInstance] setAppBackgroundTimeBeforeSessionExpires:appBackgroundTimeBeforeSessionExpires];
}

- (void)setAppBackgroundTimeBeforeSessionExpires:(NSUInteger)appBackgroundTimeBeforeSessionExpires {
  [[MSAIContextHelper sharedInstance] setAppBackgroundTimeBeforeSessionExpires:appBackgroundTimeBeforeSessionExpires];
}

+ (void)renewSessionWithId:(NSString *)sessionId {
  [[self sharedInstance] setAutoSessionManagementDisabled:YES];
  [[self sharedInstance] renewSessionWithId:sessionId];
}

- (void)renewSessionWithId:(NSString *)sessionId {
  [self setAutoSessionManagementDisabled:YES];
  [[MSAIContextHelper sharedInstance] renewSessionWithId:sessionId];
}

#pragma mark - Helper

- (BOOL)checkValidityOfInstrumentationKey:(NSString *)instrumentationKey {
  BOOL keyIsValid = NO;
  BOOL internalKey = NO;
  
  if (instrumentationKey) {
    NSCharacterSet *hexSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdef-"];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:instrumentationKey];

    keyIsValid = ([instrumentationKey length] == 36) && ([hexSet isSupersetOfSet:inStringSet]);
    internalKey = ([instrumentationKey length] == 40) && ([instrumentationKey hasPrefix:@"AIF"]);
  }
  
  return keyIsValid || internalKey;
}

- (MSAIAppClient *)appClient {
  if (!_appClient) {
    _appClient = [[MSAIAppClient alloc] initWithBaseURL:[NSURL URLWithString:_serverURL ? _serverURL : MSAI_SERVER_URL]];
  }
  
  return _appClient;
}

@end
