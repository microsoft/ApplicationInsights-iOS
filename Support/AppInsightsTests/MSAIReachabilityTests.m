#import <XCTest/XCTest.h>
#import "MSAIReachability.h"

@interface MSAIReachabilityTests : XCTestCase
@end

NSString *const testHostName = @"www.google.com";

@implementation MSAIReachabilityTests{
  MSAIReachability *_sut;
}

- (void)setUp {
  [super setUp];
  
  _sut = [MSAIReachability sharedInstance];
  [_sut configureWithAppClient:testHostName];
}

- (void)tearDown {
  _sut = nil;
  
  [super tearDown];
}

- (void)testThatItInstantiates {
  assertThat(_sut, notNilValue());
}

@end
