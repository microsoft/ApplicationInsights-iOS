#import <XCTest/XCTest.h>
#import "MSAIData.h"

@interface MSAIDataTests : XCTestCase

@end

@implementation MSAIDataTests

- (void)testbase_dataPropertyWorksAsExpected {
    MSAITelemetryData *expected = [MSAITelemetryData new];
    MSAIData *item = [MSAIData new];
    item.baseData = expected;
    MSAITelemetryData *actual = item.baseData;
    XCTAssertTrue(actual == expected);
    
    expected = [MSAITelemetryData new];
    item.baseData = expected;
    actual = item.baseData;
    XCTAssertTrue(actual == expected);
}

- (void)testSerialize {
    MSAIData *item = [MSAIData new];
    item.baseData = [MSAITelemetryData new];
    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"baseData\":{}}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
