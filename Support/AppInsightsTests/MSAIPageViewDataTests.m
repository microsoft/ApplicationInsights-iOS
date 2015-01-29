#import <XCTest/XCTest.h>
#import "MSAIPageViewData.h"

@interface MSAIPageViewDataTests : XCTestCase

@end

@implementation MSAIPageViewDataTests

- (void)testurlPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIPageViewData *item = [MSAIPageViewData new];
    item.url = expected;
    NSString *actual = item.url;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.url = expected;
    actual = item.url;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testdurationPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIPageViewData *item = [MSAIPageViewData new];
    item.duration = expected;
    NSString *actual = item.duration;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.duration = expected;
    actual = item.duration;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testSerialize {
    MSAIPageViewData *item = [MSAIPageViewData new];
    item.url = @"Test string";
    item.duration = @"Test string";
    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"ver\":2,\"properties\":{},\"measurements\":{},\"url\":\"Test string\",\"duration\":\"Test string\"}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
