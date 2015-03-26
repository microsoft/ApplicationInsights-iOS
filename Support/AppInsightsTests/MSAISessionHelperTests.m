#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "MSAISessionHelper.h"
#import "MSAISessionHelperPrivate.h"
#import "MSAIPersistence.h"
#import "MSAIPersistencePrivate.h"
#import "NotificationTests.h"

@interface MSAISessionHelperTests : NotificationTests

@property (strong) MSAISessionHelper *sut;

@end

@implementation MSAISessionHelperTests {
  
  MSAIPersistence *_persistence;
}

- (void)setUp {
  [super setUp];
  
  self.sut = [MSAISessionHelper new];
  self.sut.sessionEntries = [NSMutableDictionary new];
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
  NSString *timestamp = [self.sut unixTimestampFromDate:date];
  NSString *sessionId = @"xyz";
  [self.sut addSessionId:sessionId withDate:date];
  
  XCTAssertEqual(self.sut.sessionEntries.count, 1);
  XCTAssertEqual(self.sut.sessionEntries[timestamp], sessionId);
}

- (void)testRemoveSessionWorks {
  NSDate *key;
  NSString *value;
  for(int i = 0; i < 3; i++){
    key = [NSDate dateWithTimeIntervalSince1970:i];
    value = [NSString stringWithFormat:@"VALUE%d", i];
    [_sut addSessionId:value withDate:key];
  }
  [self.sut removeSessionId:@"VALUE1"];
  
  XCTAssertLessThanOrEqual(self.sut.sessionEntries.count, 2);
  XCTAssertNotNil(self.sut.sessionEntries[@"0"]);
  XCTAssertNotNil(self.sut.sessionEntries[@"2"]);
  XCTAssertNil(self.sut.sessionEntries[@"1"]);
  
}

- (void)testCleanUpSessionsWorks {
  XCTAssertEqual(self.sut.sessionEntries.count, 0);
  
  [self.sut addSessionId:@"a" withDate:msai_dateWithTimeIntervalSince1970(3)];
  [self.sut addSessionId:@"b" withDate:msai_dateWithTimeIntervalSince1970(33)];
  [self.sut addSessionId:@"c" withDate:msai_dateWithTimeIntervalSince1970(333)];
  XCTAssertEqual(self.sut.sessionEntries.count, 3);
  
  [self.sut cleanUpSessionIds];
  
  XCTAssertLessThanOrEqual(self.sut.sessionEntries.count, 1);
  
  XCTAssertNil(self.sut.sessionEntries[@"3"]);
  XCTAssertNil(self.sut.sessionEntries[@"33"]);
  XCTAssertNotNil(self.sut.sessionEntries[@"333"]);
}

- (void)testReturnsCorrectSessionIdForDate {
  [self.sut addSessionId:@"10" withDate:msai_dateWithTimeIntervalSince1970(3)];
  [self.sut addSessionId:@"20" withDate:msai_dateWithTimeIntervalSince1970(33)];
  [self.sut addSessionId:@"30" withDate:msai_dateWithTimeIntervalSince1970(333)];
  
  NSString *sessionId = [self.sut sessionIdForDate:[NSDate dateWithTimeIntervalSince1970:0]];
  XCTAssertNil(sessionId);
  
  sessionId = [self.sut sessionIdForDate:msai_dateWithTimeIntervalSince1970(3)];
  XCTAssertNil(sessionId);
  
  sessionId = [self.sut sessionIdForDate:msai_dateWithTimeIntervalSince1970(3+23)];
  XCTAssertEqual(sessionId, @"10");
  
  sessionId = [self.sut sessionIdForDate:msai_dateWithTimeIntervalSince1970(33)];
  XCTAssertEqual(sessionId, @"10");
  
  sessionId = [self.sut sessionIdForDate:msai_dateWithTimeIntervalSince1970(33+42)];
  XCTAssertEqual(sessionId, @"20");
  
  sessionId = [self.sut sessionIdForDate:msai_dateWithTimeIntervalSince1970(333+1337)];
  XCTAssertEqual(sessionId, @"30");
  
}

- (void)testUnixTimestampFromDate {
  NSString *timestamp = [self.sut unixTimestampFromDate:[NSDate dateWithTimeIntervalSince1970:42]];
  XCTAssertEqualObjects(timestamp, @"42");
}

- (void)testRegisterObserversOnInit {

  [verifyCount(self.mockNotificationCenter, times(4)) addObserverForName:(id)anything() object:nil queue:NSOperationQueue.mainQueue usingBlock:(id)anything()];
}

#pragma mark Helper

NSDate *msai_dateWithTimeIntervalSince1970(int timeInterval);

NSDate *msai_dateWithTimeIntervalSince1970(int timeInterval) {
  return [NSDate dateWithTimeIntervalSince1970:timeInterval];
}


@end
