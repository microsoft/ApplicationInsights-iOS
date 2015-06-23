#import <XCTest/XCTest.h>
#import "MSAIRemoteDependencyData.h"
#import "MSAIOrderedDictionary.h"

@interface MSAIRemoteDependencyDataTests : XCTestCase

@end

@implementation MSAIRemoteDependencyDataTests

- (void)testverPropertyWorksAsExpected {
  NSNumber *expected;
  expected = @42;
    MSAIRemoteDependencyData *item = [MSAIRemoteDependencyData new];
    item.version = expected;
    NSNumber *actual = item.version;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = @13;
    item.version = expected;
    actual = item.version;
    XCTAssertTrue([actual isEqual:expected]);
}

- (void)testnamePropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIRemoteDependencyData *item = [MSAIRemoteDependencyData new];
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
    MSAIRemoteDependencyData *item = [MSAIRemoteDependencyData new];
    item.kind = expected;
    MSAIDataPointType actual = item.kind;
    XCTAssertTrue(actual == expected);
    
    expected = 3;
    item.kind = expected;
    actual = item.kind;
    XCTAssertTrue(actual == expected);
}

- (void)testvaluePropertyWorksAsExpected {
    NSNumber *expected = @1.5;
    MSAIRemoteDependencyData *item = [MSAIRemoteDependencyData new];
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
    MSAIRemoteDependencyData *item = [MSAIRemoteDependencyData new];
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
    MSAIRemoteDependencyData *item = [MSAIRemoteDependencyData new];
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
    MSAIRemoteDependencyData *item = [MSAIRemoteDependencyData new];
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
    MSAIRemoteDependencyData *item = [MSAIRemoteDependencyData new];
    item.stdDev = expected;
    NSNumber *actual = item.stdDev;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = @4.8;
    item.stdDev = expected;
    actual = item.stdDev;
    XCTAssertTrue([actual isEqual:expected]);
}

- (void)testdependency_kindPropertyWorksAsExpected {
    MSAIDependencyKind expected = 5;
    MSAIRemoteDependencyData *item = [MSAIRemoteDependencyData new];
    item.dependencyKind = expected;
    MSAIDependencyKind actual = item.dependencyKind;
    XCTAssertTrue(actual == expected);
    
    expected = 3;
    item.dependencyKind = expected;
    actual = item.dependencyKind;
    XCTAssertTrue(actual == expected);
}

- (void)testsuccessPropertyWorksAsExpected {
    BOOL expected = YES;
    MSAIRemoteDependencyData *item = [MSAIRemoteDependencyData new];
    item.success = expected;
    BOOL actual = item.success;
    XCTAssertTrue(actual == expected);
    
    expected = NO;
    item.success = expected;
    actual = item.success;
    XCTAssertTrue(actual == expected);
}

- (void)testasyncPropertyWorksAsExpected {
    BOOL expected = YES;
    MSAIRemoteDependencyData *item = [MSAIRemoteDependencyData new];
    item.async = expected;
    BOOL actual = item.async;
    XCTAssertTrue(actual == expected);
    
    expected = NO;
    item.async = expected;
    actual = item.async;
    XCTAssertTrue(actual == expected);
}

- (void)testdependency_sourcePropertyWorksAsExpected {
    MSAIDependencySourceType expected = 5;
    MSAIRemoteDependencyData *item = [MSAIRemoteDependencyData new];
    item.dependencySource = expected;
    MSAIDependencySourceType actual = item.dependencySource;
    XCTAssertTrue(actual == expected);
    
    expected = 3;
    item.dependencySource = expected;
    actual = item.dependencySource;
    XCTAssertTrue(actual == expected);
}

- (void)testPropertiesPropertyWorksAsExpected {
    MSAIRemoteDependencyData *item = [MSAIRemoteDependencyData new];
    MSAIOrderedDictionary *actual = (MSAIOrderedDictionary *)item.properties;
    XCTAssertNotNil(actual, @"Pass");
}

- (void)testSerialize {
    MSAIRemoteDependencyData *item = [MSAIRemoteDependencyData new];
    item.version = @42;
    item.name = @"Test string";
    item.kind = 5;
    item.value = @1.5;
    item.count = @42;
    item.min = @1.5;
    item.max = @1.5;
    item.stdDev = @1.5;
    item.dependencyKind = 5;
    item.success = YES;
    item.async = YES;
    item.dependencySource = 5;
    item.properties = [MSAIOrderedDictionary dictionaryWithObjectsAndKeys: @"test value 1", @"key1", @"test value 2", @"key2", nil];
  
    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"ver\":42,\"name\":\"Test string\",\"kind\":5,\"value\":1.5,\"count\":42,\"min\":1.5,\"max\":1.5,\"stdDev\":1.5,\"dependencyKind\":5,\"success\":true,\"async\":true,\"dependencySource\":5,\"properties\":{\"key1\":\"test value 1\",\"key2\":\"test value 2\"}}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
