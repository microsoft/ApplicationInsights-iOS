#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"

#import "MSAIApplication.h"
#import "MSAIDevice.h"
#import "MSAIOperation.h"
#import "MSAIInternal.h"
#import "MSAIUser.h"
#import "MSAISession.h"
#import "MSAILocation.h"

@interface MSAITelemetryContextTests : XCTestCase

@end


@implementation MSAITelemetryContextTests {
  MSAITelemetryContext *_sut;
}

- (void)setUp {
  [super setUp];
  
  _sut = [self telemetryContext];
}

- (void)tearDown {
  [_sut writeSessionDefaultsWithSessionId:nil acquisitionTime:0];
  
  [super tearDown];
}

- (void)testThatItInstantiates {
  assertThat(_sut.device, notNilValue());
  assertThat(_sut.internal, notNilValue());
  assertThat(_sut.application, notNilValue());
  assertThat(_sut.session, notNilValue());
  assertThat(_sut.operation, notNilValue());
  assertThat(_sut.user, notNilValue());
  assertThat(_sut.location, notNilValue());
  assertThat(_sut.instrumentationKey, notNilValue());
  assertThat(_sut.endpointPath, notNilValue());
}

- (void)testContextDictionaryKeysAndValues{

  NSDictionary *expectedDict = @{@"ai.device.id":@"deviceId",
                                 @"ai.device.ip":@"ip",
                                 @"ai.device.language":@"language",
                                 @"ai.device.locale":@"locale",
                                 @"ai.device.model":@"model",
                                 @"ai.device.network":@"network",
                                 @"ai.device.oemName":@"oemName",
                                 @"ai.device.os":@"os",
                                 @"ai.device.osVersion":@"osVersion",
                                 @"ai.device.roleInstance":@"roleInstance",
                                 @"ai.device.roleName":@"roleName",
                                 @"ai.device.screenResolution":@"screenResolution",
                                 @"ai.device.type":@"type",
                                 @"ai.device.vmName":@"vmName",
                                 @"ai.internal.sdkVersion":@"sdkVersion",
                                 @"ai.internal.agentVersion":@"agentVersion",
                                 @"ai.application.ver":@"version",
                                 @"ai.operation.id":@"operationId",
                                 @"ai.operation.name":@"name",
                                 @"ai.operation.parentId":@"parentId",
                                 @"ai.operation.rootId":@"rootId",
                                 @"ai.user.accountAcquisitionDate":@"accountAcquisitionDate",
                                 @"ai.user.accountId":@"accountId",
                                 @"ai.user.userAgent":@"userAgent",
                                 @"ai.user.id":@"userId",
                                 @"ai.location.ip":@"ip"};
  
  NSDictionary *contextDict = [_sut contextDictionary];
  
  for(NSString *key in expectedDict.allKeys){
    assertThat(contextDict[key], equalTo(expectedDict[key]));
  }
}

- (void)testReadWriteSessionFromUserDefaults {
  
  NSString *testSessionId = @"MySessionId";
  long testAcquisitionTime = 12345;
  [_sut writeSessionDefaultsWithSessionId:testSessionId acquisitionTime:testAcquisitionTime];
  [_sut updateSessionFromSessionDefaults];
  
  assertThatLong(_sut.acquisitionMs, equalToLong(testAcquisitionTime));
  assertThat(_sut.session.sessionId, equalTo(testSessionId));
}

- (void)testIsFirstSessionAfterInitialization{
  
  long currentDateMs = [[NSDate date] timeIntervalSince1970];
  assertThatBool([_sut isFirstSession], equalToBool(YES));
  
  [_sut updateSessionContextWithDateTime:currentDateMs];
  assertThatBool([_sut isFirstSession], equalToBool(NO));
}

- (void)testRenewSession{
  
  long currentDateMs = [[NSDate date] timeIntervalSince1970];
  
  [_sut renewSessionWithCurrentDateTime:currentDateMs];
  assertThat(_sut.session.isFirst, equalTo(@"false"));
  assertThatLong(_sut.renewalMs, equalToLong(currentDateMs));
}

- (void)testCreateSession{
  long currentDateMs = [[NSDate date] timeIntervalSince1970];
  NSString *currentSessionId = _sut.session.sessionId;
  [_sut createNewSessionWithCurrentDateTime:currentDateMs];
  
  assertThat(_sut.session.sessionId, isNot(equalTo(currentSessionId)));
  assertThatLong(_sut.acquisitionMs, equalToLong(currentDateMs));
  assertThatLong(_sut.renewalMs, equalToLong(currentDateMs));
}

- (void)testUpdateValidSession{
  long currentDateMs = [[NSDate date] timeIntervalSince1970];
  long futureDateMs = currentDateMs + (1000 * 60);
  [_sut updateSessionContextWithDateTime:futureDateMs];
  NSString *currentSessionId = _sut.session.sessionId;
  
  assertThat(_sut.session.sessionId, equalTo(currentSessionId));
  assertThatLong(_sut.renewalMs, equalToLong(futureDateMs));
  assertThatLong(_sut.acquisitionMs, isNot(equalToLong(currentDateMs)));
}

- (void)testUpdateExpiredSession{
  // Start app
  long currentDateMs = [[NSDate date] timeIntervalSince1970];
  long futureDateMs = currentDateMs + (defaultSessionExpirationMs);
  
  // e.g. send first event
  [_sut updateSessionContextWithDateTime:currentDateMs];
  NSString *currentSessionId = [_sut.session.sessionId copy];
  
  // e.g. send second event after session is expired
  [_sut updateSessionContextWithDateTime:futureDateMs];
  
  assertThat(_sut.session.sessionId, isNot(equalTo(currentSessionId)));
  assertThatLong(_sut.renewalMs, equalToLong(futureDateMs));
  assertThatLong(_sut.acquisitionMs, equalToLong(futureDateMs));
}

#pragma mark - Setup helpers

- (MSAITelemetryContext *)telemetryContext{
  
  MSAIDevice *deviceContext = [MSAIDevice new];
  deviceContext.deviceId = @"deviceId";
  deviceContext.ip = @"ip";
  deviceContext.language = @"language";
  deviceContext.locale = @"locale";
  deviceContext.model = @"model";
  deviceContext.network = @"network";
  deviceContext.oemName = @"oemName";
  deviceContext.os = @"os";
  deviceContext.osVersion = @"osVersion";
  deviceContext.roleInstance = @"roleInstance";
  deviceContext.roleName = @"roleName";
  deviceContext.screenResolution = @"screenResolution";
  deviceContext.type = @"type";
  deviceContext.vmName = @"vmName";

  MSAIInternal *internalContext = [MSAIInternal new];
  internalContext.sdkVersion = @"sdkVersion";
  internalContext.agentVersion = @"agentVersion";

  MSAIApplication *applicationContext = [MSAIApplication new];
  applicationContext.version = @"version";
  
  MSAISession *sessionContext = [MSAISession new];
  sessionContext.isNew = @"isNew";
  sessionContext.isFirst = @"isFirst";
  sessionContext.sessionId = @"sessionId";
  
  MSAIOperation *operationContext = [MSAIOperation new];
  operationContext.operationId = @"operationId";
  operationContext.name = @"name";
  operationContext.parentId = @"parentId";
  operationContext.rootId = @"rootId";

  MSAIUser *userContext = [MSAIUser new];
  userContext.accountAcquisitionDate = @"accountAcquisitionDate";
  userContext.accountId = @"accountId";
  userContext.userAgent = @"userAgent";
  userContext.userId = @"userId";

  MSAILocation *locationContext = [MSAILocation new];
  locationContext.ip = @"ip";
  
  MSAITelemetryContext *telemetryContext = [[MSAITelemetryContext alloc]initWithInstrumentationKey:@"testKey"
                                                                                      endpointPath:@"test/path/to/endpoint"
                                                                                applicationContext:applicationContext
                                                                                     deviceContext:deviceContext
                                                                                   locationContext:locationContext
                                                                                    sessionContext:sessionContext
                                                                                       userContext:userContext
                                                                                   internalContext:internalContext
                                                                                  operationContext:operationContext];
  return telemetryContext;
}

@end
