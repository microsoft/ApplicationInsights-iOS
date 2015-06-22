#import <XCTest/XCTest.h>
#import "MSAITestsDependencyInjection.h"

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"

#import "MSAITelemetryManagerPrivate.h"
#import "MSAIApplication.h"
#import "MSAIDevice.h"
#import "MSAIOperation.h"
#import "MSAIInternal.h"
#import "MSAIUser.h"
#import "MSAISession.h"
#import "MSAILocation.h"
#import "MSAIContextHelper.h"

@interface MSAITelemetryContextTests : MSAITestsDependencyInjection

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
}

#ifndef CI
- (void)testContextDictionaryPerformance {
  [self measureBlock:^{
      for (int i = 0; i < 1000; ++i) {
        [_sut contextDictionary];
      }
    }];
}
#endif

#pragma mark - Setup helpers

- (MSAITelemetryContext *)telemetryContext{
  
  MSAIContext *context = [[MSAIContext alloc] initWithInstrumentationKey:@"123"];
  MSAITelemetryContext *telemetryContext = [[MSAITelemetryContext alloc] initWithAppContext:context];

  return telemetryContext;
}

@end
