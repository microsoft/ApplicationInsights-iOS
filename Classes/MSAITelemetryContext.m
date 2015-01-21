#import "MSAITelemetryContext.h"
#import "MSAIHelper.h"


#define defaultSessionRenewalMs     30 * 60 * 1000
#define defaultSessionExpirationMs  24 * 60 * 60 * 1000

NSString *const kMSAITelemetrySessionId = @"MSAITelemetrySessionId";
NSString *const kMSAISessionAcquisitionTime = @"MSAISessionAcquisitionTime";

@implementation MSAITelemetryContext{
  long _acquisitionMs;
  long _renewalMs;
}

- (instancetype)initWithInstrumentationKey:(NSString *)instrumentationKey
                              endpointPath:(NSString *)endpointPath
                        applicationContext:(MSAIApplication *)applicationContext
                             deviceContext:(MSAIDevice *)deviceContext
                           locationContext:(MSAILocation *)locationContext
                            sessionContext:(MSAISession *)sessionContext
                               userContext:(MSAIUser *)userContext
                           internalContext:(MSAIInternal *)internalContext
                          operationContext:(MSAIOperation *)operationContext{
  if ((self = [self init])) {
    _instrumentationKey = instrumentationKey;
    _endpointPath = endpointPath;
    _application = applicationContext;
    _device = deviceContext;
    _location = locationContext;
    _user = userContext;
    _internal = internalContext;
    _operation = operationContext;
    _session = sessionContext;
    [self updateSessionFromSessionDefaults];
  }
  return self;
}

- (NSDictionary *)contextDictionary{
  
  NSMutableDictionary *contextDictionary = [self.application serializeToDictionary];
  
  [self updateSessionContext];
  [contextDictionary addEntriesFromDictionary:[self.session serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.device serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.location serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.user serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.internal serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.operation serializeToDictionary]];
  
  return contextDictionary;
}

- (void)updateSessionContext {
  long currentDateMs = [[NSDate date] timeIntervalSince1970];
  
  BOOL firstSession = _acquisitionMs == 0 || _renewalMs == 0;
  BOOL acqExpired = (currentDateMs  - _acquisitionMs) > defaultSessionExpirationMs;
  BOOL renewalExpired = (currentDateMs - _renewalMs) > defaultSessionRenewalMs;
  
  [_session setIsFirst: (firstSession ? @"true" : @"false")];
  
  if (firstSession || acqExpired || renewalExpired) {
    [_session setSessionId:[_device deviceId]];
    [_session setIsFirst:@"true"];
    
    _renewalMs = currentDateMs;
    _acquisitionMs = currentDateMs;
    
    [self writeSessionDefaultsWithSessionId:[_session sessionId] acquisitionTime:_acquisitionMs];
  }else{
    _renewalMs = currentDateMs;
    [_session setIsFirst:@"false"];
  }
}

- (void)writeSessionDefaultsWithSessionId:(NSString *)sessionId acquisitionTime:(long)acquisitionTime{
  [[NSUserDefaults standardUserDefaults] setObject:[_session sessionId] forKey:kMSAITelemetrySessionId];
  [[NSUserDefaults standardUserDefaults] setObject:@(_acquisitionMs) forKey:kMSAISessionAcquisitionTime];
}

- (void)updateSessionFromSessionDefaults{
  NSNumber *acquisitionTime = [[NSUserDefaults standardUserDefaults]objectForKey:kMSAISessionAcquisitionTime];
  _acquisitionMs = [acquisitionTime longValue];
  NSString *sessionId = [[NSUserDefaults standardUserDefaults]objectForKey:kMSAITelemetrySessionId];
  [_session setSessionId:sessionId];
}

@end
