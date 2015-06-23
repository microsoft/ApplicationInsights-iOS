#import <XCTest/XCTest.h>
#import "MSAIEventData.h"
#import "MSAIOrderedDictionary.h"

@interface MSAIEventDataTests : XCTestCase

@end

@implementation MSAIEventDataTests

- (void)testverPropertyWorksAsExpected {
    NSNumber *expected = @42;
    MSAIEventData *item = [MSAIEventData new];
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
    MSAIEventData *item = [MSAIEventData new];
    item.name = expected;
    NSString *actual = item.name;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.name = expected;
    actual = item.name;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testPropertiesPropertyWorksAsExpected {
    MSAIEventData *item = [MSAIEventData new];
    MSAIOrderedDictionary *actual = (MSAIOrderedDictionary *)item.properties;
    XCTAssertNotNil(actual, @"Pass");
}

- (void)testMeasurementsPropertyWorksAsExpected {
    MSAIEventData *item = [MSAIEventData new];
    MSAIOrderedDictionary *actual = (MSAIOrderedDictionary *)item.measurements;
    XCTAssertNotNil(actual, @"Pass");
}

- (void)testSerialize {
    MSAIEventData *item = [MSAIEventData new];
    item.version = @42;
    item.name = @"Test string";
    item.properties = [MSAIOrderedDictionary dictionaryWithObjectsAndKeys: @"test value 1", @"key1", @"test value 2", @"key2", nil];
    item.measurements = [MSAIOrderedDictionary dictionaryWithObjectsAndKeys:@3.1415, @"key1", @42.2, @"key2", nil];
  
    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"ver\":42,\"name\":\"Test string\",\"properties\":{\"key1\":\"test value 1\",\"key2\":\"test value 2\"},\"measurements\":{\"key1\":3.1415,\"key2\":42.2}}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
