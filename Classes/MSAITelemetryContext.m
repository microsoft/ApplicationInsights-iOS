#import "MSAITelemetryContext.h"
#import "MSAIHelper.h"


static NSInteger defaultSessionRenewalMs = 30 * 60 * 1000; // 30 minutes
static NSInteger defaultSessionExpirationMs = 24 * 60 * 60 * 1000; // 24 hours

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
    _session = sessionContext;
    _user = userContext;
    _internal = internalContext;
    _operation = operationContext;
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
    
    [[NSUserDefaults standardUserDefaults] setValue:[_session sessionId] forKey:kMSAITelemetrySessionId];
    [[NSUserDefaults standardUserDefaults] setInteger:_acquisitionMs forKey:kMSAISessionAcquisitionTime];
  }else{
    _renewalMs = currentDateMs;
    [_session setIsFirst:@"false"];
  }
}

@end
