#import <XCTest/XCTest.h>
#import "MSAIDomain.h"

@interface MSAIDomainTests : XCTestCase

@end

@implementation MSAIDomainTests

- (void)testSerialize {
    MSAIDomain *item = [MSAIDomain new];
    NSString *actual = [item serializeToString];
    NSString *expected = @"{}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
