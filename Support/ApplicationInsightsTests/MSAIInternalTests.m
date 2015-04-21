#import <XCTest/XCTest.h>
#import "MSAIInternal.h"

@interface MSAIInternalTests : XCTestCase

@end

@implementation MSAIInternalTests

- (void)testsdk_versionPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIInternal *item = [MSAIInternal new];
    item.sdkVersion = expected;
    NSString *actual = item.sdkVersion;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.sdkVersion = expected;
    actual = item.sdkVersion;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testagent_versionPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIInternal *item = [MSAIInternal new];
    item.agentVersion = expected;
    NSString *actual = item.agentVersion;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.agentVersion = expected;
    actual = item.agentVersion;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testSerialize {
    MSAIInternal *item = [MSAIInternal new];
    item.sdkVersion = @"Test string";
    item.agentVersion = @"Test string";
    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"ai.internal.sdkVersion\":\"Test string\",\"ai.internal.agentVersion\":\"Test string\"}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
