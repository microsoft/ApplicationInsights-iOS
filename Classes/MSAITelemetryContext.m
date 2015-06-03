#import <Foundation/Foundation.h>
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAITelemetryManagerPrivate.h"
#import "MSAIHelper.h"
#import "MSAIContextHelper.h"
#import "MSAIContextHelperPrivate.h"
#import "MSAIReachability.h"
#import "MSAIReachabilityPrivate.h"

NSString *const kMSAITelemetrySessionId = @"MSAITelemetrySessionId";
NSString *const kMSAISessionAcquisitionTime = @"MSAISessionAcquisitionTime";

@implementation MSAITelemetryContext

#pragma mark - Initialisation

- (instancetype)initWithAppContext:(MSAIContext *)appContext {
  
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
    
    MSAISession *sessionContext = [[MSAIContextHelper sharedInstance] newSession];
    [[MSAIContextHelper sharedInstance] addSession:sessionContext withDate:[NSDate date]];
    
    MSAIOperation *operationContext = [MSAIOperation new];
    
    MSAIUser *userContext = [[MSAIContextHelper sharedInstance] userForDate:[NSDate date]];
    if (!userContext) {
      userContext = [[MSAIContextHelper sharedInstance] newUser];
      [[MSAIContextHelper sharedInstance] addUser:userContext forDate:[NSDate date]];
    }
    
    MSAILocation *locationContext = [MSAILocation new];
    
    _instrumentationKey = appContext.instrumentationKey;
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
                    MSAISession *session = userInfo[kMSAISessionInfoSession];
                    _session = session;
                  }];
}

#pragma mark - User

- (void)configureUserTracking {
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserverForName:MSAIUserIdChangedNotification
                      object:nil
                       queue:nil
                  usingBlock:^(NSNotification *note) {
                    NSDictionary *userInfo = note.userInfo;
                    NSString *userId = userInfo[kMSAIUserInfoUserId];
                    if (_user) {
                      _user.userId = userId;
                    } else {
                      _user = [[MSAIContextHelper sharedInstance] newUserWithId:userId];
                    }
                  }];
  
}

#pragma mark - Custom getter
#pragma mark - Helper

- (MSAIOrderedDictionary *)contextDictionary {
  MSAIOrderedDictionary *contextDictionary = [MSAIOrderedDictionary new];
  [contextDictionary addEntriesFromDictionary:self.tags];
  [contextDictionary addEntriesFromDictionary:[self.session serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.user serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.device serializeToDictionary]];
  
  return contextDictionary;
}

- (MSAIOrderedDictionary *)tags {
  if(!_tags){
    _tags = [self.application serializeToDictionary];
    [_tags addEntriesFromDictionary:[self.application serializeToDictionary]];
    [_tags addEntriesFromDictionary:[self.location serializeToDictionary]];
    [_tags addEntriesFromDictionary:[self.internal serializeToDictionary]];
    [_tags addEntriesFromDictionary:[self.operation serializeToDictionary]];
  }
  return _tags;
}

@end
