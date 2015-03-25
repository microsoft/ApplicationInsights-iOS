#import <XCTest/XCTest.h>


#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "AppInsights.h"
#import "AppInsightsPrivate.h"
#import "MSAICrashManager.h"
#import "MSAICrashManagerPrivate.h"
#import "MSAIContextPrivate.h"
#import "MSAIPersistence.h"
#import "MSAIEnvelope.h"
#import "MSAICrashData.h"
#import "MSAITestHelper.h"
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAIEnvelopeManager.h"
#import "MSAIEnvelopeManagerPrivate.h"

#define kMSAICrashMetaAttachment @"MSAICrashMetaAttachment"

#if MSAI_FEATURE_CRASH_REPORTER

@interface MSAICrashManagerTests : XCTestCase

@end


@implementation MSAICrashManagerTests {
  BOOL _startManagerInitialized;
}

- (void)setUp {
  [super setUp];
  
  _startManagerInitialized = NO;
  
  MSAIContext *context = [[MSAIContext alloc]initWithInstrumentationKey:@"123"];
  MSAITelemetryContext *telemetryContext = [[MSAITelemetryContext alloc] initWithAppContext:context endpointPath:nil];
  [[MSAIEnvelopeManager sharedManager] configureWithTelemetryContext:telemetryContext];

}

- (void)tearDown {
  [super tearDown];
}

#pragma mark - Helpers for start/stop

- (void)startManager {
  [MSAICrashManager sharedManager].isCrashManagerDisabled = NO;
  if(!_startManagerInitialized) {
    [[MSAICrashManager sharedManager] startManager];
  }
  _startManagerInitialized = YES;
}

- (void)startManagerDisabled {
  [MSAICrashManager sharedManager].isCrashManagerDisabled = YES;
  if(!_startManagerInitialized) {
    [[MSAICrashManager sharedManager] startManager];
  }
  _startManagerInitialized = YES;
}


#pragma mark - Setup Tests

- (void)testThatItInstantiates {
  XCTAssertNotNil([MSAICrashManager sharedManager], @"Should be there");
}

- (void)testThatItIsSetup {
  [self startManager];
  XCTAssertTrue([[MSAICrashManager sharedManager] isSetupCorrectly]);
}

#pragma mark - Debugger

/**
 *  We are running this usually witin Xcode
 *  TODO: what to do if we do run this e.g. on Jenkins or Xcode bots ?
 */
- (void)testIsDebuggerAttached {
  assertThatBool([MSAICrashManager sharedManager].debuggerIsAttached, equalToBool(YES));
}

- (void)testStartManagerWithModuleDisabled {
  [self startManagerDisabled];
  assertThatBool([MSAICrashManager sharedManager].isCrashManagerDisabled, equalToBool(YES));
}

#pragma mark - Crash Reporting

- (void)testHasPendingCrashReportWithNoFiles {
  [MSAICrashManager sharedManager].isCrashManagerDisabled = NO;
  assertThatBool([[MSAICrashManager sharedManager].plCrashReporter hasPendingCrashReport], equalToBool(NO));
}

- (void)testCreateCrashReportForAppKill {
  //handle app kill (FakeCrashReport will be generated)
  [[MSAICrashManager sharedManager] createCrashReportForAppKill]; //just creates a fake crash report and hands it over to MSAIPersistence
  
  NSArray *bundle = [[MSAIPersistence sharedInstance] crashTemplateBundle];
  XCTAssertNil(bundle);
  
  if(bundle && ([bundle count] > 0)) {
    id envelope = [bundle firstObject];
    if(envelope && [envelope isKindOfClass:[MSAIEnvelope class]]) {
      assertThatBool([((MSAIEnvelope *) envelope).data isKindOfClass:[MSAICrashData class]], equalToBool(YES));
    }
  }
}

#pragma mark - StartManager

- (void)testStartPLCrashReporterSetup {
  // since PLCR is only initialized once ever, we need to pack all tests that rely on a PLCR instance
  // in this test method. Ugly but otherwise this would require a major redesign of MSAICrashManager
  // which we can't do at this moment
  // This also limits us not being able to test various scenarios having a custom exception handler
  // which would require us to run without a debugger anyway and which would also require a redesign
  // to make this better testable with unit tests
  
  id delegateMock = mockProtocol(@protocol(MSAICrashManagerDelegate));
  [MSAICrashManager sharedManager].delegate = delegateMock;

  [self startManager];
  
  assertThat([MSAICrashManager sharedManager].plCrashReporter, notNilValue());
  
  // When running from the debugger this is always nil and not the exception handler from PLCR
  NSUncaughtExceptionHandler *currentHandler = NSGetUncaughtExceptionHandler();
  
  BOOL result = ([MSAICrashManager sharedManager].exceptionHandler == currentHandler);
  
  assertThatBool(result, equalToBool(YES));
  
  // No files at startup
  assertThatBool([[MSAICrashManager sharedManager].plCrashReporter hasPendingCrashReport], equalToBool(NO));
  
  [[MSAICrashManager sharedManager] readCrashReportAndStartProcessing];
  
  // handle a new empty crash report
  assertThatBool([MSAITestHelper copyFixtureCrashReportWithFileName:@"live_report_empty"], equalToBool(YES));
  
    assertThatBool([[MSAICrashManager sharedManager].plCrashReporter hasPendingCrashReport], equalToBool(YES));

  [[MSAICrashManager sharedManager] readCrashReportAndStartProcessing];
  
  // we should have 0 pending crash report
  assertThatBool([[MSAICrashManager sharedManager].plCrashReporter hasPendingCrashReport], equalToBool(NO));
  
    // handle a new signal crash report
  assertThatBool([MSAITestHelper copyFixtureCrashReportWithFileName:@"live_report_signal"], equalToBool(YES));
  
  // we should have now 1 pending crash report
  assertThatBool([[MSAICrashManager sharedManager].plCrashReporter hasPendingCrashReport], equalToBool(YES));

  [[MSAICrashManager sharedManager] readCrashReportAndStartProcessing];
  
  // handle a new signal crash report
  assertThatBool([MSAITestHelper copyFixtureCrashReportWithFileName:@"live_report_exception"], equalToBool(YES));
  
    // we should have now 1 pending crash report
  assertThatBool([[MSAICrashManager sharedManager].plCrashReporter hasPendingCrashReport], equalToBool(YES));
  
  [[MSAICrashManager sharedManager] readCrashReportAndStartProcessing];
}

@end
#endif
