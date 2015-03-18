#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "MSAISessionHelper.h"
#import "MSAISessionHelperPrivate.h"
#import "MSAIPersistence.h"

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
  [super tearDown];
  
  // Reset property list
}

#pragma mark - Setup Tests

- (void)testAddSessionWorks {
  
  NSString *timestamp = @"1234";
  NSString *sessionId = @"xyz";
  [MSAISessionHelper addSessionId:sessionId withTimestamp:timestamp];
  
  XCTAssertLessThanOrEqual(_sut.sessionEntries.count, 1);
  XCTAssertTrue([_sut.sessionEntries[timestamp] isEqualToString:sessionId]);
}

- (void)testRemoveSessionWorks {
  NSString *key;
  NSString *value;
  for(int i = 0; i < 3; i++){
    key = [NSString stringWithFormat:@"%d", i];
    value = [NSString stringWithFormat:@"VALUE%d", i];
    [MSAISessionHelper addSessionId:value withTimestamp:key];
  }
  [MSAISessionHelper removeSessionId:@"VALUE1"];
  
  XCTAssertLessThanOrEqual(_sut.sessionEntries.count, 2);
  XCTAssertNotNil(_sut.sessionEntries[@"0"]);
  XCTAssertNotNil(_sut.sessionEntries[@"2"]);
  XCTAssertNil(_sut.sessionEntries[@"1"]);
  
}

- (void)testCleanUpSessionsWorks {
  [MSAISessionHelper addSessionId:@"x" withTimestamp:@"3"];
  [MSAISessionHelper addSessionId:@"x" withTimestamp:@"333"];
  [MSAISessionHelper addSessionId:@"x" withTimestamp:@"33"];
  [MSAISessionHelper cleanUpSessionIds];
  
  XCTAssertLessThanOrEqual(_sut.sessionEntries.count, 1);
  XCTAssertNil(_sut.sessionEntries[@"33"]);
  XCTAssertNil(_sut.sessionEntries[@"3"]);
  XCTAssertNotNil(_sut.sessionEntries[@"333"]);
}

- (void)testReturnsCorrectSessionIdForTimestamp {
  [MSAISessionHelper addSessionId:@"10" withTimestamp:@"10"];
  [MSAISessionHelper addSessionId:@"20" withTimestamp:@"20"];
  [MSAISessionHelper addSessionId:@"30" withTimestamp:@"30"];
  
  NSString *sessionId = [MSAISessionHelper sessionIdForTimestamp:@"7"];
  XCTAssertNil(sessionId);
  
  sessionId = [MSAISessionHelper sessionIdForTimestamp:@"10"];
  XCTAssertNil(sessionId);
  
  sessionId = [MSAISessionHelper sessionIdForTimestamp:@"15"];
  XCTAssertEqual(sessionId, @"10");
  
  sessionId = [MSAISessionHelper sessionIdForTimestamp:@"21"];
  XCTAssertEqual(sessionId, @"20");
  
  sessionId = [MSAISessionHelper sessionIdForTimestamp:@"33"];
  XCTAssertEqual(sessionId, @"30");
  
}

@end
