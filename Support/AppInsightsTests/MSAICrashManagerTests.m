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

#define kMSAICrashMetaAttachment @"MSAICrashMetaAttachment"

#if MSAI_FEATURE_CRASH_REPORTER

@interface MSAICrashManagerTests : XCTestCase

@end


@implementation MSAICrashManagerTests {
  MSAICrashManager *_sut;
  MSAIContext *_context;
  BOOL _startManagerInitialized;
}

- (void)setUp {
  [super setUp];
  
  _startManagerInitialized = NO;
  
  _context = [[MSAIContext alloc]initWithInstrumentationKey:nil];
  _sut = [MSAICrashManager sharedManager];
}

- (void)tearDown {
  [_sut cleanCrashReports];
  [super tearDown];
}

#pragma mark - Private

- (void)startManager {
  [_sut startManager];
  [NSObject cancelPreviousPerformRequestsWithTarget:_sut selector:@selector(invokeDelayedProcessing) object:nil];
  _startManagerInitialized = YES;
}

- (void)startManagerDisabled {
  _sut.isCrashManagerDisabled = YES;
  if (_startManagerInitialized) return;
  [self startManager];
}


#pragma mark - Setup Tests

- (void)testThatItInstantiates {
  XCTAssertNotNil(_sut, @"Should be there");
}

- (void)testThatItIsSetup {
  [self startManager];
  XCTAssertTrue(_sut.isSetupCorrectly);
}


#pragma mark - Helper


#pragma mark - Debugger

/**
 *  We are running this usually witin Xcode
 *  TODO: what to do if we do run this e.g. on Jenkins or Xcode bots ?
 */
- (void)testIsDebuggerAttached {
  assertThatBool([_sut getIsDebuggerAttached], equalToBool(YES));
}


#pragma mark - Internals

- (void)testHasPendingCrashReportWithNoFiles {
  _sut.isCrashManagerDisabled = NO;
  assertThatBool([_sut hasPendingCrashReport], equalToBool(NO));
}

- (void)testFirstNotApprovedCrashReportWithNoFiles {
  _sut.isCrashManagerDisabled = NO;
  assertThat([_sut firstNotApprovedCrashReport], equalTo(nil));
}

- (void)testCreateCrashReportForAppKill {
  [_sut createCrashReportForAppKill]; //just creates a crash template and hands it over to MSAIPersistence
  
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

- (void)testStartManagerWithModuleDisabled {
  [self startManagerDisabled];
  assertThatBool(_sut.isCrashManagerDisabled, equalToBool(YES));
}

- (void)testStartManagerWithAutoSend {
  // since PLCR is only initialized once ever, we need to pack all tests that rely on a PLCR instance
  // in this test method. Ugly but otherwise this would require a major redesign of MSAICrashManager
  // which we can't do at this moment
  // This also limits us not being able to test various scenarios having a custom exception handler
  // which would require us to run without a debugger anyway and which would also require a redesign
  // to make this better testable with unit tests
  
  id delegateMock = mockProtocol(@protocol(MSAICrashManagerDelegate));
  _sut.delegate = delegateMock;

  [self startManager];
  
  assertThat(_sut.plCrashReporter, notNilValue());
  
  // When running from the debugger this is always nil and not the exception handler from PLCR
  NSUncaughtExceptionHandler *currentHandler = NSGetUncaughtExceptionHandler();
  
  BOOL result = (_sut.exceptionHandler == currentHandler);
  
  assertThatBool(result, equalToBool(YES));
  
  // No files at startup
  assertThatBool([_sut hasPendingCrashReport], equalToBool(NO));
  assertThat([_sut firstNotApprovedCrashReport], equalTo(nil));
  
  [_sut invokeDelayedProcessing];
  
  // handle a new empty crash report
  assertThatBool([MSAITestHelper copyFixtureCrashReportWithFileName:@"live_report_empty"], equalToBool(YES));
  
  [_sut handleCrashReport];
  
  // we should have 0 pending crash report
  assertThatBool([_sut hasPendingCrashReport], equalToBool(NO));
  assertThat([_sut firstNotApprovedCrashReport], equalTo(nil));
  
  [_sut cleanCrashReports];
  
  // handle a new signal crash report
  assertThatBool([MSAITestHelper copyFixtureCrashReportWithFileName:@"live_report_signal"], equalToBool(YES));
  
  [_sut handleCrashReport];
  
  // we should have now 1 pending crash report
  assertThatBool([_sut hasPendingCrashReport], equalToBool(YES));
  assertThat([_sut firstNotApprovedCrashReport], notNilValue());
  
  [_sut cleanCrashReports];

  // handle a new signal crash report
  assertThatBool([MSAITestHelper copyFixtureCrashReportWithFileName:@"live_report_exception"], equalToBool(YES));
  
  [_sut handleCrashReport];
  
  // we should have now 1 pending crash report
  assertThatBool([_sut hasPendingCrashReport], equalToBool(YES));
  assertThat([_sut firstNotApprovedCrashReport], notNilValue());
  
  [_sut cleanCrashReports];
  
  }

@end
#endif
