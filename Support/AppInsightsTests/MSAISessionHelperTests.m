#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "MSAISessionHelper.h"
#import "MSAISessionHelperPrivate.h"

@interface MSAISessionHelperTests : XCTestCase

@end


@implementation MSAISessionHelperTests {
  MSAISessionHelper *_sut;
}

- (void)setUp {
  [super setUp];
  
  _sut = [MSAISessionHelper sharedInstance];
  _sut.sessionEntries = [NSMutableDictionary new];
}

- (void)teardown {
  [super tearDown];
  
  // Reset property list
}

#pragma mark - Setup Tests

- (void)testAddSessionWorks {
  
  XCTAssertLessThanOrEqual(_sut.sessionEntries.count, 0);
  NSString *timestamp = @"1234";
  NSString *sessionId = @"xyz";
  
  [MSAISessionHelper addSessionId:sessionId withTimestamp:timestamp];
  XCTAssertLessThanOrEqual(_sut.sessionEntries.count, 1);
  XCTAssertEqual(_sut.sessionEntries[timestamp], sessionId);
  
  [_sut loadFile];
  XCTAssertLessThanOrEqual(_sut.sessionEntries.count, 1);
  XCTAssertEqual(_sut.sessionEntries[timestamp], sessionId);
}

@end
