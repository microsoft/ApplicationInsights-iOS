#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "MSAISessionHelper.h"
#import "MSAISessionHelperPrivate.h"
#import "MSAIPersistence.h"
#import "MSAIPersistencePrivate.h"

@interface MSAISessionHelperTests : XCTestCase

@end


@implementation MSAISessionHelperTests {
  MSAISessionHelper *_sut;
  MSAIPersistence *_persistence;
}

- (void)setUp {
  [super setUp];
  
  _sut = [MSAISessionHelper sharedInstance];
  _sut.sessionEntries = [NSMutableDictionary new];
  assertThatInteger(_sut.sessionEntries.count, equalToInteger(0));
}

- (void)teardown {
  NSString *path = [[MSAIPersistence sharedInstance] newFileURLForPersitenceType:MSAIPersistenceTypeSessionIds];
  [[MSAIPersistence sharedInstance] deleteFileAtPath:path];
  
  [super tearDown];
}

#pragma mark - Setup Tests

- (void)testAddSessionWorks {
  
  NSDate *date = [NSDate date];
  NSString *timestamp = [_sut unixTimestampFromDate:date];
  NSString *sessionId = @"xyz";
  [MSAISessionHelper addSessionId:sessionId withDate:date];
  
  XCTAssertEqual(_sut.sessionEntries.count, 1);
  XCTAssertEqual(_sut.sessionEntries[timestamp], sessionId);
}

- (void)testRemoveSessionWorks {
  NSDate *key;
  NSString *value;
  for(int i = 0; i < 3; i++){
    key = [NSDate dateWithTimeIntervalSince1970:i];
    value = [NSString stringWithFormat:@"VALUE%d", i];
    [_sut addSessionId:value withDate:key];
  }
  [MSAISessionHelper removeSessionId:@"VALUE1"];
  
  XCTAssertLessThanOrEqual(_sut.sessionEntries.count, 2);
  XCTAssertNotNil(_sut.sessionEntries[@"0"]);
  XCTAssertNotNil(_sut.sessionEntries[@"2"]);
  XCTAssertNil(_sut.sessionEntries[@"1"]);
  
}

- (void)testCleanUpSessionsWorks {
  XCTAssertEqual(_sut.sessionEntries.count, 0);
  
  [MSAISessionHelper addSessionId:@"a" withDate:msai_dateWithTimeIntervalSince1970(3)];
  [MSAISessionHelper addSessionId:@"b" withDate:msai_dateWithTimeIntervalSince1970(33)];
  [MSAISessionHelper addSessionId:@"c" withDate:msai_dateWithTimeIntervalSince1970(333)];
  XCTAssertEqual(_sut.sessionEntries.count, 3);
  
  [MSAISessionHelper cleanUpSessionIds];
  
  XCTAssertLessThanOrEqual(_sut.sessionEntries.count, 1);
  
  XCTAssertNil(_sut.sessionEntries[@"3"]);
  XCTAssertNil(_sut.sessionEntries[@"33"]);
  XCTAssertNotNil(_sut.sessionEntries[@"333"]);
}

- (void)testReturnsCorrectsessionIdForDate {
  [MSAISessionHelper addSessionId:@"10" withDate:msai_dateWithTimeIntervalSince1970(3)];
  [MSAISessionHelper addSessionId:@"20" withDate:msai_dateWithTimeIntervalSince1970(33)];
  [MSAISessionHelper addSessionId:@"30" withDate:msai_dateWithTimeIntervalSince1970(333)];
  
  NSString *sessionId = [MSAISessionHelper sessionIdForDate:[NSDate dateWithTimeIntervalSince1970:0]];
  XCTAssertNil(sessionId);
  
  sessionId = [MSAISessionHelper sessionIdForDate:msai_dateWithTimeIntervalSince1970(3)];
  XCTAssertNil(sessionId);
  
  sessionId = [MSAISessionHelper sessionIdForDate:msai_dateWithTimeIntervalSince1970(3+23)];
  XCTAssertEqual(sessionId, @"10");
  
  sessionId = [MSAISessionHelper sessionIdForDate:msai_dateWithTimeIntervalSince1970(33)];
  XCTAssertEqual(sessionId, @"10");
  
  sessionId = [MSAISessionHelper sessionIdForDate:msai_dateWithTimeIntervalSince1970(33+42)];
  XCTAssertEqual(sessionId, @"20");
  
  sessionId = [MSAISessionHelper sessionIdForDate:msai_dateWithTimeIntervalSince1970(333+1337)];
  XCTAssertEqual(sessionId, @"30");
  
}

- (void)testUnixTimestampFromDate {
  NSString *timestamp = [_sut unixTimestampFromDate:[NSDate dateWithTimeIntervalSince1970:42]];
  XCTAssertEqualObjects(timestamp, @"42");
}

#pragma mark Helper

NSDate *msai_dateWithTimeIntervalSince1970(int timeInterval);

NSDate *msai_dateWithTimeIntervalSince1970(int timeInterval) {
  return [NSDate dateWithTimeIntervalSince1970:timeInterval];
}


@end
