#import <XCTest/XCTest.h>
#import "MSAIHTTPOperation.h"

@interface MSAIHTTPOperationTests : XCTestCase

@property MSAIHTTPOperation *sut;

@end

@implementation MSAIHTTPOperationTests

- (void)setUp {
  [super setUp];
  
  self.sut = [MSAIHTTPOperation new];
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

#pragma mark Convenience Initializer

- (void)testOperationWithRequest {
  NSURLRequest *testRequest = [NSURLRequest new];
  
  MSAIHTTPOperation *sut = [MSAIHTTPOperation operationWithRequest:testRequest];
  
  XCTAssertEqualObjects(sut.URLRequest, testRequest);
}

@end
