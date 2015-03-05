#import <Foundation/Foundation.h>
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAIMetricsManagerPrivate.h"
#import "MSAIHelper.h"
#import "MSAIReachability.h"
#import "MSAIReachabilityPrivate.h"

NSString *const kMSAITelemetrySessionId = @"MSAITelemetrySessionId";
NSString *const kMSAISessionAcquisitionTime = @"MSAISessionAcquisitionTime";

@implementation MSAITelemetryContext

#pragma mark - Initialisation

- (instancetype)initWithAppContext:(MSAIContext *)appContext
                      endpointPath:(NSString *)endpointPath{
  
  if ((self = [self init])) {

    MSAIDevice *deviceContext = [MSAIDevice new];
    deviceContext.model = appContext.deviceModel;
    deviceContext.type = appContext.deviceType;
    deviceContext.osVersion = appContext.osVersion;
    deviceContext.os = appContext.osName;
    
    //TODO: Get device id from appContext
    deviceContext.deviceId = msai_appAnonID();
    deviceContext.locale = msai_deviceLocale();
    deviceContext.language = msai_deviceLanguage();
    deviceContext.screenResolution = msai_screenSize();
    deviceContext.oemName = @"Apple";
    
    MSAIInternal *internalContext = [MSAIInternal new];
    internalContext.sdkVersion = msai_sdkVersion();
    
    MSAIApplication *applicationContext = [MSAIApplication new];
    applicationContext.version = appContext.appVersion;
    
    MSAISession *sessionContext = [MSAISession new];
    
    MSAIOperation *operationContext = [MSAIOperation new];
    
    MSAIUser *userContext = [MSAIUser new];
    userContext.userId = msai_appAnonID();
    
    MSAILocation *locationContext = [MSAILocation new];
    
    _instrumentationKey = appContext.instrumentationKey;
    _endpointPath = endpointPath;
    _userDefaults = NSUserDefaults.standardUserDefaults;
    _application = applicationContext;
    _device = deviceContext;
    _location = locationContext;
    _user = userContext;
    _internal = internalContext;
    _operation = operationContext;
    _session = sessionContext;
    
    [self createNewSession];
    [self configureNetworkStatusTracking];
  }
  return self;
}

- (void)dealloc{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Network

- (void)configureNetworkStatusTracking{
  [[MSAIReachability sharedInstance] startNetworkStatusTracking];
  _device.network = [[MSAIReachability sharedInstance] descriptionForActiveReachabilityType];
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserver:self selector:@selector(updateNetworkType:) name:kMSAIReachabilityTypeChangedNotification object:nil];
}

-(void)updateNetworkType:(NSNotification *)notification{
  
  @synchronized(self){
    _device.network = [[notification userInfo]objectForKey:kMSAIReachabilityUserInfoName];
  }
}

#pragma mark - Session

- (void)updateSessionContext {
  if ([_session.isNew isEqualToString:@"true"]) {
    _session.isNew = @"false";
  }
}

- (BOOL)isFirstSession{
  return ![_userDefaults boolForKey:kMSAIApplicationWasLaunched];
}

- (void)createNewSession {
  BOOL firstSession = [self isFirstSession];
  _session.sessionId = msai_UUID();
  _session.isNew = @"true";
  _session.isFirst = (firstSession ? @"true" : @"false");
}

#pragma mark - Helper

- (MSAIOrderedDictionary *)contextDictionary {
  MSAIOrderedDictionary *contextDictionary = [self.application serializeToDictionary];
  [contextDictionary addEntriesFromDictionary:[self.session serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.device serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.location serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.user serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.internal serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.operation serializeToDictionary]];
  [self updateSessionContext];
  
  return contextDictionary;
}

@end
