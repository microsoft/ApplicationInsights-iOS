#import <XCTest/XCTest.h>
#import "MSAILocation.h"

@interface MSAILocationTests : XCTestCase

@end

@implementation MSAILocationTests

- (void)testipPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAILocation *item = [MSAILocation new];
    item.ip = expected;
    NSString *actual = item.ip;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.ip = expected;
    actual = item.ip;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testSerialize {
    MSAILocation *item = [MSAILocation new];
    item.ip = @"Test string";
    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"ai.location.ip\":\"Test string\"}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
