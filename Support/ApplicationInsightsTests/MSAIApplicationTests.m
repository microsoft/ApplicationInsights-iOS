#import <XCTest/XCTest.h>
#import "MSAIApplication.h"

@interface MSAIApplicationTests : XCTestCase

@end

@implementation MSAIApplicationTests

- (void)testverPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIApplication *item = [MSAIApplication new];
    item.version = expected;
    NSString *actual = item.version;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.version = expected;
    actual = item.version;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testSerialize {
    MSAIApplication *item = [MSAIApplication new];
    item.version = @"Test string";
    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"ai.application.ver\":\"Test string\"}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
