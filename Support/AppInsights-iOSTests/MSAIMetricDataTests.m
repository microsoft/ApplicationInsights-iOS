#import <XCTest/XCTest.h>
#import "MSAIMetricData.h"
#import "MSAIDataPoint.h"

@interface MSAIMetricDataTests : XCTestCase

@end

@implementation MSAIMetricDataTests

- (void)testverPropertyWorksAsExpected {
    NSNumber *expected = [NSNumber numberWithInt:42];
    MSAIMetricData *item = [MSAIMetricData new];
    item.version = expected;
    NSNumber *actual = item.version;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = [NSNumber numberWithInt:13];
    item.version = expected;
    actual = item.version;
    XCTAssertTrue([actual isEqual:expected]);
}

- (void)testMetricsPropertyWorksAsExpected {
    MSAIMetricData *item = [MSAIMetricData new];
    NSMutableArray *actual = (NSMutableArray *)item.metrics;
    XCTAssertNotNil(actual, @"Pass");
}

- (void)testPropertiesPropertyWorksAsExpected {
    MSAIMetricData *item = [MSAIMetricData new];
    MSAIOrderedDictionary *actual = (MSAIOrderedDictionary *)item.properties;
    XCTAssertNotNil(actual, @"Pass");
}

- (void)testSerialize {
    MSAIMetricData *item = [MSAIMetricData new];
    item.version = [NSNumber numberWithInt:42];
    NSArray *arrmetrics = [NSArray arrayWithObjects: [MSAIDataPoint new], nil];
    for (MSAIDataPoint *arrItem in arrmetrics) {
        [item.metrics addObject:arrItem];
    }
    item.properties = [MSAIOrderedDictionary dictionaryWithObjectsAndKeys: @"test value 1", @"key1", @"test value 2", @"key2", nil];

    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"ver\":42,\"metrics\":[{\"kind\":0}],\"properties\":{\"key1\":\"test value 1\",\"key2\":\"test value 2\"}}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
