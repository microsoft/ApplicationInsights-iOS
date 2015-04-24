#import <XCTest/XCTest.h>
#import "MSAIMessageData.h"

@interface MSAIMessageDataTests : XCTestCase

@end

@implementation MSAIMessageDataTests

- (void)testverPropertyWorksAsExpected {
  NSNumber *expected;
  expected = @42;
    MSAIMessageData *item = [MSAIMessageData new];
    item.version = expected;
    NSNumber *actual = item.version;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = @13;
    item.version = expected;
    actual = item.version;
    XCTAssertTrue([actual isEqual:expected]);
}

- (void)testmessagePropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIMessageData *item = [MSAIMessageData new];
    item.message = expected;
    NSString *actual = item.message;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.message = expected;
    actual = item.message;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testseverity_levelPropertyWorksAsExpected {
    MSAISeverityLevel expected = 5;
    MSAIMessageData *item = [MSAIMessageData new];
    item.severityLevel = expected;
    MSAISeverityLevel actual = item.severityLevel;
    XCTAssertTrue(actual == expected);
    
    expected = 3;
    item.severityLevel = expected;
    actual = item.severityLevel;
    XCTAssertTrue(actual == expected);
}

- (void)testPropertiesPropertyWorksAsExpected {
    MSAIMessageData *item = [MSAIMessageData new];
    MSAIOrderedDictionary *actual = (MSAIOrderedDictionary *)item.properties;
    XCTAssertNotNil(actual, @"Pass");
}

- (void)testSerialize {
    MSAIMessageData *item = [MSAIMessageData new];
    item.version = @42;
    item.message = @"Test string";
    item.severityLevel = 5;
    item.properties = [MSAIOrderedDictionary dictionaryWithObjectsAndKeys: @"test value 1", @"key1", @"test value 2", @"key2", nil];

    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"ver\":42,\"message\":\"Test string\",\"severityLevel\":5,\"properties\":{\"key1\":\"test value 1\",\"key2\":\"test value 2\"}}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
