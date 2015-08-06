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
    item.build = @"Test build";
    item.typeId = @"Test typeId";
    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"ai.application.ver\":\"Test string\",\"ai.application.build\":\"Test build\",\"ai.application.typeId\":\"Test typeId\"}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
