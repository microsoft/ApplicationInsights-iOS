#import <Foundation/Foundation.h>
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAITelemetryManagerPrivate.h"
#import "MSAIHelper.h"
#import "MSAIContextHelper.h"
#import "MSAIContextHelperPrivate.h"
#import "MSAIReachability.h"
#import "MSAIReachabilityPrivate.h"
#import "MSAIOrderedDictionary.h"

NSString *const kMSAITelemetrySessionId = @"MSAITelemetrySessionId";
NSString *const kMSAISessionAcquisitionTime = @"MSAISessionAcquisitionTime";

static char *const MSAIContextOperationsQueue = "com.microsoft.ApplicationInsights.telemetryContextQueue";

@implementation MSAITelemetryContext

@synthesize instrumentationKey = _instrumentationKey;

#pragma mark - Initialisation

- (instancetype)initWithInstrumentationKey:(NSString *)instrumentationKey {
  
  if ((self = [self init])) {
    
    _operationsQueue = dispatch_queue_create(MSAIContextOperationsQueue, DISPATCH_QUEUE_SERIAL);
    _instrumentationKey = instrumentationKey;
    MSAIDevice *deviceContext = [MSAIDevice new];
    deviceContext.model = msai_devicePlatform();
    deviceContext.type = msai_deviceType();
    deviceContext.osVersion = msai_osVersionBuild();
    deviceContext.os = msai_osName();
    deviceContext.deviceId = msai_appAnonID();
    deviceContext.locale = msai_deviceLocale();
    deviceContext.language = msai_deviceLanguage();
    deviceContext.screenResolution = msai_screenSize();
    deviceContext.oemName = @"Apple";
    
    MSAIInternal *internalContext = [MSAIInternal new];
    internalContext.sdkVersion = msai_sdkVersion();
    
    MSAIApplication *applicationContext = [MSAIApplication new];
    applicationContext.version = msai_appVersion();
    
    MSAISession *sessionContext = [[MSAIContextHelper sharedInstance] newSession];
    [[MSAIContextHelper sharedInstance] addSession:sessionContext withDate:[NSDate date]];
    NSDictionary *userInfo = @{kMSAISessionInfo : sessionContext};
    [[MSAIContextHelper sharedInstance] sendSessionStartedNotificationWithUserInfo:userInfo];
    
    MSAIOperation *operationContext = [MSAIOperation new];
    
    MSAIUser *userContext = [[MSAIContextHelper sharedInstance] userForDate:[NSDate date]];
    if (!userContext) {
      userContext = [[MSAIContextHelper sharedInstance] newUser];
      [[MSAIContextHelper sharedInstance] addUser:userContext forDate:[NSDate date]];
    }
    
    MSAILocation *locationContext = [MSAILocation new];
    
    _application = applicationContext;
    _device = deviceContext;
    _location = locationContext;
    _user = userContext;
    _internal = internalContext;
    _operation = operationContext;
    _session = sessionContext;
    _tags = [self tags];
    
    
    [self configureUserTracking];
    [self configureNetworkStatusTracking];
    [self configureSessionTracking];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Network

- (void)configureNetworkStatusTracking {
  [[MSAIReachability sharedInstance] startNetworkStatusTracking];
  _device.network = [[MSAIReachability sharedInstance] descriptionForActiveReachabilityType];
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserver:self selector:@selector(updateNetworkType:) name:kMSAIReachabilityTypeChangedNotification object:nil];
}

- (void)updateNetworkType:(NSNotification *)notification {
  
  @synchronized(self){
    _device.network = [notification userInfo][kMSAIReachabilityUserInfoName];
  }
}

#pragma mark - Session

- (void)configureSessionTracking {
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserverForName:MSAISessionStartedNotification
                      object:nil
                       queue:nil
                  usingBlock:^(NSNotification *notification) {
                    NSDictionary *userInfo = notification.userInfo;
                    MSAISession *session = userInfo[kMSAISessionInfo];
                    _session = session;
                  }];
}

#pragma mark - User

- (void)configureUserTracking {
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserverForName:MSAIUserChangedNotification
                      object:nil
                       queue:nil
                  usingBlock:^(NSNotification *note) {
                    NSDictionary *userInfo = note.userInfo;
                    MSAIUser *user = userInfo[kMSAIUserInfo];
                    if (_user) {
                      _user = user;
                    }
                  }];
  
}

#pragma mark - Getter/Setter properties

- (NSString *)instrumentationKey {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _instrumentationKey;
  });
  return tmp;
}

- (void)setInstrumentationKey:(NSString *)instrumentationKey {
  NSString* tmp = [instrumentationKey copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _instrumentationKey = tmp;
  });
}

- (NSString *)screenResolution {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _device.screenResolution;
  });
  return tmp;
}

- (void)setScreenResolution:(NSString *)screenResolution {
  NSString* tmp = [screenResolution copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _device.screenResolution = tmp;
  });
}

- (NSString *)appVersion {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _application.version;
  });
  return tmp;
}

- (void)setAppVersion:(NSString *)appVersion {
  NSString* tmp = [appVersion copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _application.version = tmp;
  });
}

- (NSString *)userId {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _user.userId;
  });
  return tmp;
}

- (void)setUserId:(NSString *)userId {
  NSString* tmp = [userId copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _user.userId = tmp;
  });
}

- (NSString *)userAcquisitionDate {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _user.accountAcquisitionDate;
  });
  return tmp;
}

- (void)setUserAcquisitionDate:(NSString *)userAcqusitionDate {
  NSString* tmp = [userAcqusitionDate copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _user.accountAcquisitionDate = tmp;
  });
}

- (NSString *)accountId {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _user.accountId;
  });
  return tmp;
}

- (void)setAccountId:(NSString *)accountId {
  NSString* tmp = [accountId copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _user.accountId = tmp;
  });
}

- (NSString *)authenticatedUserId {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _user.authUserId;
  });
  return tmp;
}

- (void)setAuthenticatedUserId:(NSString *)authenticatedUserId {
  NSString* tmp = [authenticatedUserId copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _user.authUserId = tmp;
  });
}

- (NSString *)authenticatedUserAcquisitionDate {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _user.authUserAcquisitionDate;
  });
  return tmp;
}

- (void)setAuthenticatedUserAcquisitionDate:(NSString *)authenticatedUserAcquisitionDate {
  NSString* tmp = [authenticatedUserAcquisitionDate copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _user.authUserAcquisitionDate = tmp;
  });
}

- (NSString *)anonymousUserAquisitionDate {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _user.anonUserAcquisitionDate;
  });
  return tmp;
}

- (void)setAnonymousUserAquisitionDate:(NSString *)anonymousUserAquisitionDate {
  NSString* tmp = [anonymousUserAquisitionDate copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _user.anonUserAcquisitionDate = tmp;
  });
}

- (NSString *)sdkVersion {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _internal.sdkVersion;
  });
  return tmp;
}

- (void)setSdkVersion:(NSString *)sdkVersion {
  NSString* tmp = [sdkVersion copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _internal.sdkVersion = tmp;
  });
}

- (NSString *)sessionId {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _session.sessionId;
  });
  return tmp;
}

- (void)setSessionId:(NSString *)sessionId {
  NSString* tmp = [sessionId copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _session.sessionId = tmp;
  });
}

- (NSString *)osVersion {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _device.osVersion;
  });
  return tmp;
}

- (void)setOsVersion:(NSString *)osVersion {
  NSString* tmp = [osVersion copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _device.osVersion = tmp;
  });
}

- (NSString *)osName {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _device.os;
  });
  return tmp;
}

- (void)setOsName:(NSString *)osName {
  NSString* tmp = [osName copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _device.os = tmp;
  });
}

- (NSString *)deviceModel {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _device.model;
  });
  return tmp;
}

- (void)setDeviceModel:(NSString *)deviceModel {
  NSString* tmp = [deviceModel copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _device.model = tmp;
  });
}

- (NSString *)deviceOemName {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _device.oemName;
  });
  return tmp;
}

- (void)setDeviceOemName:(NSString *)oemName {
  NSString* tmp = [oemName copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _device.oemName = tmp;
  });
}

- (NSString *)osLocale {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _device.locale;
  });
  return tmp;
}

- (void)setOsLocale:(NSString *)osLocale {
  NSString* tmp = [osLocale copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _device.locale = tmp;
  });
}

- (NSString *)deviceId {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _device.deviceId;
  });
  return tmp;
}

- (void)setDeviceId:(NSString *)deviceId {
  NSString* tmp = [deviceId copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _device.deviceId = tmp;
  });
}

- (NSString *)deviceType {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _device.type;
  });
  return tmp;
}

- (void)setDeviceType:(NSString *)deviceType {
  NSString* tmp = [deviceType copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _device.type = tmp;
  });
}

- (NSString *)networkType {
  __block NSString *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _device.network;
  });
  return tmp;
}

- (void)setNetworkType:(NSString *)networkType {
  NSString* tmp = [networkType copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _device.network = tmp;
  });
}
- (void)setTelemetryContextWithConfigurationBlock:(void (^)(MSAITelemetryContext *telemetryContext))telemetryContextConfigurationBlock{
  telemetryContextConfigurationBlock(self);
}

#pragma mark - Custom getter
#pragma mark - Helper

- (MSAIOrderedDictionary *)contextDictionary {
  MSAIOrderedDictionary *contextDictionary = [MSAIOrderedDictionary new];
  [contextDictionary addEntriesFromDictionary:[self.session serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.user serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.device serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.application serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.location serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.internal serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.operation serializeToDictionary]];
  
  return contextDictionary;
}

@end
