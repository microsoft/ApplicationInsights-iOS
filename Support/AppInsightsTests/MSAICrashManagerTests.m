#if MSAI_FEATURE_CRASH_REPORTER
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

#import "MSAITestHelper.h"

#define kMSAICrashMetaAttachment @"MSAICrashMetaAttachment"

@interface MSAICrashManagerTests : XCTestCase

@end


@implementation MSAICrashManagerTests {
  MSAICrashManager *_sut;
  BOOL _startManagerInitialized;
}

- (void)setUp {
  [super setUp];
  
  _startManagerInitialized = NO;
  
  MSAIContext *appContext = [[MSAIContext alloc]initWithInstrumentationKey:nil isAppStoreEnvironment:NO];
  _sut = [[MSAICrashManager alloc] initWithAppContext:appContext];
}

- (void)tearDown {
# pragma clang diagnostic push
# pragma clang diagnostic ignored "-Wimplicit"
  __gcov_flush();
# pragma clang diagnostic pop
  
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
  _sut.crashManagerStatus = MSAICrashManagerStatusDisabled;
  if (_startManagerInitialized) return;
  [self startManager];
}

- (void)startManagerAutoSend {
  _sut.crashManagerStatus = MSAICrashManagerStatusAutoSend;
  if (_startManagerInitialized) return;
  [self startManager];
}

#pragma mark - Setup Tests

- (void)testThatItInstantiates {
  XCTAssertNotNil(_sut, @"Should be there");
}


#pragma mark - Persistence tests

- (void)testPersistUserProvidedMetaData {
  NSString *tempCrashName = @"tempCrash";
  [_sut setLastCrashFilename:tempCrashName];
  
  MSAICrashMetaData *metaData = [MSAICrashMetaData new];
  [metaData setUserDescription:@"Test string"];
  [_sut persistUserProvidedMetaData:metaData];
  
  NSError *error;
  NSString *description = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@.desc", [[_sut crashesDir] stringByAppendingPathComponent: tempCrashName]] encoding:NSUTF8StringEncoding error:&error];
  assertThat(description, equalTo(@"Test string"));
}


#pragma mark - Helper

- (void)testUserIDForCrashReport {
  MSAIManager *tm = [MSAIManager sharedMSAIManager];
  id delegateMock = mockProtocol(@protocol(MSAIManagerDelegate));
  tm.delegate = delegateMock;
  _sut.delegate = delegateMock;
  
  NSString *result = [_sut userIDForCrashReport];
  
  assertThat(result, notNilValue());

  [verifyCount(delegateMock, times(1)) userIDForTelemetryManager:tm componentManager:_sut];
}

- (void)testUserNameForCrashReport {
  MSAIManager *hm = [MSAIManager sharedMSAIManager];
  id delegateMock = mockProtocol(@protocol(MSAIManagerDelegate));
  hm.delegate = delegateMock;
  _sut.delegate = delegateMock;
  
  NSString *result = [_sut userNameForCrashReport];
  
  assertThat(result, notNilValue());
  
  [verifyCount(delegateMock, times(1)) userNameForTelemetryManager:hm componentManager:_sut];
}

- (void)testUserEmailForCrashReport {
  MSAIManager *hm = [MSAIManager sharedMSAIManager];
  id delegateMock = mockProtocol(@protocol(MSAIManagerDelegate));
  hm.delegate = delegateMock;
  _sut.delegate = delegateMock;
  
  NSString *result = [_sut userEmailForCrashReport];
  
  assertThat(result, notNilValue());
  
  [verifyCount(delegateMock, times(1)) userEmailForTelemetryManager:hm componentManager:_sut];
}

#pragma mark - Handle User Input

- (void)testHandleUserInputDontSend {
  id <MSAICrashManagerDelegate> delegateMock = mockProtocol(@protocol(MSAICrashManagerDelegate));
  _sut.delegate = delegateMock;
  
  assertThatBool([_sut handleUserInput:MSAICrashManagerUserInputDontSend withUserProvidedMetaData:nil], equalToBool(YES));
  
  [verify(delegateMock) crashManagerWillCancelSendingCrashReport:_sut];
  
}

- (void)testHandleUserInputSend {
  assertThatBool([_sut handleUserInput:MSAICrashManagerUserInputSend withUserProvidedMetaData:nil], equalToBool(YES));
}

- (void)testHandleUserInputAlwaysSend {
  id <MSAICrashManagerDelegate> delegateMock = mockProtocol(@protocol(MSAICrashManagerDelegate));
  _sut.delegate = delegateMock;
  NSUserDefaults *mockUserDefaults = mock([NSUserDefaults class]);
  
  //Test if CrashManagerStatus is unset
  [given([mockUserDefaults integerForKey:@"MSAICrashManagerStatus"]) willReturn:nil];
  
  //Test if method runs through
  assertThatBool([_sut handleUserInput:MSAICrashManagerUserInputAlwaysSend withUserProvidedMetaData:nil], equalToBool(YES));
  
  //Test if correct CrashManagerStatus is now set
  [given([mockUserDefaults integerForKey:@"MSAICrashManagerStauts"]) willReturnInt:MSAICrashManagerStatusAutoSend];
  
  //Verify that delegate method has been called
  [verify(delegateMock) crashManagerWillSendCrashReportsAlways:_sut];
  
}

- (void)testHandleUserInputWithInvalidInput {
  assertThatBool([_sut handleUserInput:3 withUserProvidedMetaData:nil], equalToBool(NO));
}

#pragma mark - Debugger

/**
 *  We are running this usually witin Xcode
 *  TODO: what to do if we do run this e.g. on Jenkins or Xcode bots ?
 */
- (void)testIsDebuggerAttached {
  assertThatBool([_sut debuggerIsAttached], equalToBool(YES));
}


#pragma mark - Helper

- (void)testHasPendingCrashReportWithNoFiles {
  _sut.crashManagerStatus = MSAICrashManagerStatusAutoSend;
  assertThatBool([_sut hasPendingCrashReport], equalToBool(NO));
}

- (void)testFirstNotApprovedCrashReportWithNoFiles {
  _sut.crashManagerStatus = MSAICrashManagerStatusAutoSend;
  assertThat([_sut firstNotApprovedCrashReport], equalTo(nil));
}


#pragma mark - StartManager

- (void)testStartManagerWithModuleDisabled {
  [self startManagerDisabled];
  
  assertThat(_sut.plCrashReporter, equalTo(nil));
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

  [self startManagerAutoSend];
  
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
  
  [verifyCount(delegateMock, times(1)) applicationLogForCrashManager:_sut];
  
  // we should have now 1 pending crash report
  assertThatBool([_sut hasPendingCrashReport], equalToBool(YES));
  assertThat([_sut firstNotApprovedCrashReport], notNilValue());
  
  // this is currently sending blindly, needs refactoring to test properly
  [_sut sendNextCrashReport];
  [verifyCount(delegateMock, times(1)) crashManagerWillSendCrashReport:_sut];
  
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
