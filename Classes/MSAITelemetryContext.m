#import <Foundation/Foundation.h>
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAIHelper.h"

NSString *const kMSAITelemetrySessionId = @"MSAITelemetrySessionId";
NSString *const kMSAISessionAcquisitionTime = @"MSAISessionAcquisitionTime";

@implementation MSAITelemetryContext

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

- (MSAIOrderedDictionary *)contextDictionary{
  
  long currentDateMs = [[NSDate date] timeIntervalSince1970];
  [self updateSessionContextWithDateTime:currentDateMs];
  MSAIOrderedDictionary *contextDictionary = [self.application serializeToDictionary];
  [contextDictionary addEntriesFromDictionary:[self.session serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.device serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.location serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.user serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.internal serializeToDictionary]];
  [contextDictionary addEntriesFromDictionary:[self.operation serializeToDictionary]];
  
  return contextDictionary;
}

- (void)writeSessionDefaultsWithSessionId:(NSString *)sessionId acquisitionTime:(long)acquisitionTime{
  [[NSUserDefaults standardUserDefaults] setObject:sessionId forKey:kMSAITelemetrySessionId];
  [[NSUserDefaults standardUserDefaults] setDouble:acquisitionTime forKey:kMSAISessionAcquisitionTime];
}

- (void)updateSessionFromSessionDefaults{
  _session.sessionId = [[NSUserDefaults standardUserDefaults]objectForKey:kMSAITelemetrySessionId];
  _acquisitionMs = [[NSUserDefaults standardUserDefaults]doubleForKey:kMSAISessionAcquisitionTime];
}

#pragma mark - Helper

- (void)updateSessionContextWithDateTime:(long)dateTime {
  BOOL acqExpired = (dateTime  - _acquisitionMs) > defaultSessionExpirationMs;
  BOOL renewalExpired = (dateTime - _renewalMs) > defaultSessionRenewalMs;
  BOOL firstSession = [self isFirstSession];
  _session.isFirst = (firstSession ? @"true" : @"false");
  
  if (firstSession || acqExpired || renewalExpired) {
    [self createNewSessionWithCurrentDateTime:dateTime];
  }else{
    [self renewSessionWithCurrentDateTime:dateTime];
  }
}

- (BOOL)isFirstSession{
  return _acquisitionMs == 0 || _renewalMs == 0;
}

- (void)createNewSessionWithCurrentDateTime:(long)dateTime{
  _session.sessionId = msai_UUID();
  _session.isFirst = @"true";
  _renewalMs = dateTime;
  _acquisitionMs = dateTime;
  [self writeSessionDefaultsWithSessionId:[_session sessionId] acquisitionTime:_acquisitionMs];
}

- (void)renewSessionWithCurrentDateTime:(long)dateTime{
  _renewalMs = dateTime;
  _session.isFirst = @"false";
}

@end
