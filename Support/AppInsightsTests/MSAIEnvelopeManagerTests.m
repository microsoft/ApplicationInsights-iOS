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
#import <CrashReporter/CrashReporter.h>
#import <pthread.h>

@interface MSAIEnvelopeManagerTests : XCTestCase

@end

@implementation MSAIEnvelopeManagerTests {
  MSAIEnvelopeManager *_sut;
  MSAITelemetryContext *_telemetryContext;
}

- (void)setUp {
  [super setUp];
  
  MSAIContext *context = [[MSAIContext alloc]initWithInstrumentationKey:@"123"];
  _telemetryContext = [[MSAITelemetryContext alloc]initWithAppContext:context endpointPath:nil];
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

- (void)testThatItInstantiatesEnvelopeForCrash {
  PLCrashReporterSignalHandlerType signalHandlerType = PLCrashReporterSignalHandlerTypeBSD;
  PLCrashReporterSymbolicationStrategy symbolicationStrategy = PLCrashReporterSymbolicationStrategyAll;
  MSAIPLCrashReporterConfig *config = [[MSAIPLCrashReporterConfig alloc] initWithSignalHandlerType: signalHandlerType
                                                                             symbolicationStrategy: symbolicationStrategy];
  MSAIPLCrashReporter *cm = [[MSAIPLCrashReporter alloc] initWithConfiguration:config];
  NSData *data = [cm generateLiveReportWithThread:pthread_mach_thread_np(pthread_self())];
  MSAIPLCrashReport *report = [[MSAIPLCrashReport alloc] initWithData:data error:nil];
  MSAIEnvelope *envelope = [_sut envelopeForCrashReport:report];
  
  [self checkEnvelopeTemplate:envelope];
  assertThat(envelope.data, notNilValue());
  assertThat(envelope.name, equalTo(@"Microsoft.ApplicationInsights.Crash"));
}

#pragma mark - Helper

- (void)checkEnvelopeTemplate:(MSAIEnvelope *)template{
  assertThat(template, notNilValue());
  assertThat(template.time, notNilValue());
  assertThat(template.tags, notNilValue());
  assertThat(template.iKey, equalTo(@"123"));
}

@end
