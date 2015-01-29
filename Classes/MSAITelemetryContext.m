#import <Foundation/Foundation.h>
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAIMetricsManagerPrivate.h"
#import "MSAIHelper.h"

NSString *const kMSAITelemetrySessionId = @"MSAITelemetrySessionId";
NSString *const kMSAISessionAcquisitionTime = @"MSAISessionAcquisitionTime";

@implementation MSAITelemetryContext

#pragma mark - Initialisation

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
    _userDefaults = NSUserDefaults.standardUserDefaults;
    _application = applicationContext;
    _device = deviceContext;
    _location = locationContext;
    _user = userContext;
    _internal = internalContext;
    _operation = operationContext;
    _session = sessionContext;
    [self createNewSession];
  }
  return self;
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
