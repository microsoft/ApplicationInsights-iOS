#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MSAIApplicationInsightsPrivate.h"
#import "MSAIApplicationInsights.h"

@interface MSAIManagerTests : XCTestCase

@property (nonatomic, strong) MSAIApplicationInsights *sut;

@end

@implementation MSAIManagerTests

- (void)setUp {
  [super setUp];
  self.sut = [MSAIApplicationInsights new];
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void)testCheckValidityOfInstrumentationKey {
  NSString *validInstrumentationKey = @"d604e87f-7530-0675-9606-cb358fe8ac76";
  NSString *invalidInstrumentationKey = @"ff5c62817410e2413a67c5df144dc35c";
  
  XCTAssertTrue([self.sut checkValidityOfInstrumentationKey:validInstrumentationKey]);
  
  XCTAssertFalse([self.sut checkValidityOfInstrumentationKey:invalidInstrumentationKey]);
  XCTAssertFalse([self.sut checkValidityOfInstrumentationKey:@""]);
}

@end
