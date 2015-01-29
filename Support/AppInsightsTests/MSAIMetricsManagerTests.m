#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "AppInsights.h"
#import "AppInsightsPrivate.h"
#import "MSAIAppClient.h"
#import "MSAIMetricsManager.h"
#import "MSAIMetricsManagerPrivate.h"
#import "MSAIBaseManager.h"
#import "MSAIBaseManagerPrivate.h"
#import "MSAIContextPrivate.h"
#import "MSAIContext.h"
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"

@interface MSAIMetricsManagerTests : XCTestCase

@end


@implementation MSAIMetricsManagerTests

- (void)setUp {
  [super setUp];
  
  MSAIAppClient *appClient = mockClass([MSAIAppClient class]);
  MSAIContext *appContext = [[MSAIContext alloc]initWithInstrumentationKey:@"245251431" isAppStoreEnvironment:NO];
  [MSAIMetricsManager configureWithContext:appContext appClient:appClient];
  [MSAIMetricsManager startManager];
}

#pragma mark - Setup Tests

- (void)testThatItInstantiates {
  assertThat([MSAIMetricsManager context], notNilValue());
  assertThat([MSAIMetricsManager channel], notNilValue());
  assertThat([MSAIMetricsManager telemetryContext], notNilValue());
}

#pragma mark - Helper

- (void)testTelemetryChannel {
  MSAITelemetryContext *testContext = [MSAIMetricsManager telemetryContext];
  
  assertThat([testContext instrumentationKey], notNilValue());
  assertThat([testContext endpointPath], equalTo(MSAI_TELEMETRY_PATH));
  assertThat([testContext application], notNilValue());
  assertThat([testContext device], notNilValue());
  assertThat([testContext location], notNilValue());
  assertThat([testContext session], notNilValue());
  assertThat([testContext user], notNilValue());
  assertThat([testContext internal], notNilValue());
  assertThat([testContext operation], notNilValue());
}

@end
