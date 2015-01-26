#import <XCTest/XCTest.h>
#import "MSAIDataPoint.h"

@interface MSAIDataPointTests : XCTestCase

@end

@implementation MSAIDataPointTests

- (void)testnamePropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIDataPoint *item = [MSAIDataPoint new];
    item.name = expected;
    NSString *actual = item.name;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.name = expected;
    actual = item.name;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testkindPropertyWorksAsExpected {
    MSAIDataPointType expected = 5;
    MSAIDataPoint *item = [MSAIDataPoint new];
    item.kind = expected;
    MSAIDataPointType actual = item.kind;
    XCTAssertTrue(actual == expected);
    
    expected = 3;
    item.kind = expected;
    actual = item.kind;
    XCTAssertTrue(actual == expected);
}

- (void)testvaluePropertyWorksAsExpected {
  NSNumber *expected;
  expected = @1.5;
    MSAIDataPoint *item = [MSAIDataPoint new];
    item.value = expected;
    NSNumber *actual = item.value;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = @4.8;
    item.value = expected;
    actual = item.value;
    XCTAssertTrue([actual isEqual:expected]);
}

- (void)testcountPropertyWorksAsExpected {
    NSNumber *expected = @42;
    MSAIDataPoint *item = [MSAIDataPoint new];
    item.count = expected;
    NSNumber *actual = item.count;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = @13;
    item.count = expected;
    actual = item.count;
    XCTAssertTrue([actual isEqual:expected]);
}

- (void)testminPropertyWorksAsExpected {
    NSNumber *expected = @1.5;
    MSAIDataPoint *item = [MSAIDataPoint new];
    item.min = expected;
    NSNumber *actual = item.min;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = @4.8;
    item.min = expected;
    actual = item.min;
    XCTAssertTrue([actual isEqual:expected]);
}

- (void)testmaxPropertyWorksAsExpected {
    NSNumber *expected = @1.5;
    MSAIDataPoint *item = [MSAIDataPoint new];
    item.max = expected;
    NSNumber *actual = item.max;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = @4.8;
    item.max = expected;
    actual = item.max;
    XCTAssertTrue([actual isEqual:expected]);
}

- (void)teststd_devPropertyWorksAsExpected {
    NSNumber *expected = @1.5;
    MSAIDataPoint *item = [MSAIDataPoint new];
    item.stdDev = expected;
    NSNumber *actual = item.stdDev;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = @4.8;
    item.stdDev = expected;
    actual = item.stdDev;
    XCTAssertTrue([actual isEqual:expected]);
}

- (void)testSerialize {
    MSAIDataPoint *item = [MSAIDataPoint new];
    item.name = @"Test string";
    item.kind = 5;
    item.value = @1.5;
    item.count = @42;
    item.min = @1.5;
    item.max = @1.5;
    item.stdDev = @1.5;
    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"name\":\"Test string\",\"kind\":5,\"value\":1.5,\"count\":42,\"min\":1.5,\"max\":1.5,\"stdDev\":1.5}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
