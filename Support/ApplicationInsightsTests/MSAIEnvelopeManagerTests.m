#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "MSAIAppClient.h"
#import "MSAIEnvelopeManager.h"
#import "MSAIEnvelopeManagerPrivate.h"
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAIEnvelope.h"
#import "MSAIApplication.h"
#import "MSAIEventData.h"
#import "MSAIData.h"

@interface MSAIEnvelopeManagerTests : XCTestCase

@end

@implementation MSAIEnvelopeManagerTests {
  MSAIEnvelopeManager *_sut;
  MSAITelemetryContext *_telemetryContext;
}

- (void)setUp {
  [super setUp];
  
  MSAIContext *context = [[MSAIContext alloc]initWithInstrumentationKey:@"123"];
  _telemetryContext = [[MSAITelemetryContext alloc] initWithAppContext:context];
  [[MSAIEnvelopeManager sharedManager] configureWithTelemetryContext:_telemetryContext];
  _sut = [MSAIEnvelopeManager sharedManager];
}

#pragma mark - Setup Tests

- (void)testThatItInstantiates {
  assertThat(_sut, notNilValue());
  assertThat(_sut.telemetryContext, notNilValue());
}

- (void)testThatItInstantiatesEnvelopeTemplate {
  MSAIEnvelope *template = [_sut envelope];
  
  [self checkEnvelopeTemplate:template];
}

#ifndef CI
- (void)testEnvelopePerformance {
  [self measureBlock:^{
    for (int i = 0; i < 1000; ++i) {
      [_sut envelope];
    }
  }];
}
#endif

- (void)testThatItInstantiatesEnvelopeForTelemetryData {
  MSAIEventData *testEvent = [MSAIEventData new];
  testEvent.name = @"Test event";
  
  MSAIEnvelope *envelope = [_sut envelopeForTelemetryData:testEvent];
  assertThat(envelope.data, notNilValue());
  assertThat(envelope.name, equalTo(@"Microsoft.ApplicationInsights.Event"));
  
  MSAIData *data = (MSAIData *)envelope.data;
  [self checkEnvelopeTemplate:envelope];
  assertThat(data.baseData, instanceOf([MSAIEventData class]));
  assertThat([(MSAIEventData *)data.baseData name], equalTo(@"Test event"));
  assertThat(data.baseType, equalTo(@"EventData"));
}

#pragma mark - Helper

- (void)checkEnvelopeTemplate:(MSAIEnvelope *)template{
  assertThat(template, notNilValue());
  assertThat(template.time, notNilValue());
  assertThat(template.tags, notNilValue());
  assertThat(template.iKey, equalTo(@"123"));
}

@end
