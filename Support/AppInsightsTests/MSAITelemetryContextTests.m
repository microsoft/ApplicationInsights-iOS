#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"

#import "MSAIMetricsManagerPrivate.h"
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

- (void)testContextDictionaryUpdateSessionContext {
  [_sut createNewSession];
  MSAISession *session = _sut.session;
  XCTAssertTrue([session.isNew isEqualToString:@"true"]);
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Wunused"
  MSAIOrderedDictionary *contextDict = _sut.contextDictionary;
  #pragma clang diagnostic pop
  XCTAssertTrue([session.isNew isEqualToString:@"false"]);
}

- (void)testUpdateSessionContext {
  _sut.session.isNew = @"true";
  [_sut updateSessionContext];
  
  XCTAssertTrue([_sut.session.isNew isEqualToString:@"false"]);
}

- (void)testContextDictionaryPerformance {
    [self measureBlock:^{
      for (int i = 0; i < 1000; ++i) {
        [_sut contextDictionary];
      }
    }];
}

- (void)testIsFirstSession {
  NSUserDefaults *userDefaults = [NSUserDefaults new];
  _sut.userDefaults = userDefaults;
  
  [userDefaults setBool:NO forKey:kMSAIApplicationWasLaunched];
  assertThatBool([_sut isFirstSession], equalToBool(YES));
  
  [userDefaults setBool:YES forKey:kMSAIApplicationWasLaunched];
  assertThatBool([_sut isFirstSession], equalToBool(NO));
}

- (void)testCreateNewSession {
  MSAISession *session = _sut.session;
  NSUserDefaults *userDefaults = [NSUserDefaults new];
  _sut.userDefaults = userDefaults;
  [userDefaults setBool:YES forKey:kMSAIApplicationWasLaunched];

  [_sut createNewSession];
  XCTAssertTrue([session.isNew isEqualToString:@"true"]);
  XCTAssertTrue([session.isFirst isEqualToString:@"false"]);
  
  NSString *firstGUID = session.sessionId;

  [_sut createNewSession];
  XCTAssertFalse([firstGUID isEqualToString:session.sessionId]);
}

#pragma mark - Setup helpers

- (MSAITelemetryContext *)telemetryContext{
  
  MSAIContext *context = [[MSAIContext alloc]initWithInstrumentationKey:@"123"];
  MSAITelemetryContext *telemetryContext = [[MSAITelemetryContext alloc]initWithAppContext:context endpointPath:@"path"];

  return telemetryContext;
}

@end
