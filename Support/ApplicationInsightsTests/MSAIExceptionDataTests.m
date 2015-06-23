#import <XCTest/XCTest.h>
#import "MSAIExceptionData.h"
#import "MSAIExceptionDetails.h"
#import "MSAIOrderedDictionary.h"

@interface MSAIExceptionDataTests : XCTestCase

@end

@implementation MSAIExceptionDataTests

- (void)testverPropertyWorksAsExpected {
  NSNumber *expected;
  expected = @42;
    MSAIExceptionData *item = [MSAIExceptionData new];
    item.version = expected;
    NSNumber *actual = item.version;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = @13;
    item.version = expected;
    actual = item.version;
    XCTAssertTrue([actual isEqual:expected]);
}

- (void)testhandled_atPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIExceptionData *item = [MSAIExceptionData new];
    item.handledAt = expected;
    NSString *actual = item.handledAt;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.handledAt = expected;
    actual = item.handledAt;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testExceptionsPropertyWorksAsExpected {
    MSAIExceptionData *item = [MSAIExceptionData new];
    NSMutableArray *actual = (NSMutableArray *)item.exceptions;
    XCTAssertNotNil(actual, @"Pass");
}

- (void)testseverity_levelPropertyWorksAsExpected {
    MSAISeverityLevel expected = 5;
    MSAIExceptionData *item = [MSAIExceptionData new];
    item.severityLevel = expected;
    MSAISeverityLevel actual = item.severityLevel;
    XCTAssertTrue(actual == expected);
    
    expected = 3;
    item.severityLevel = expected;
    actual = item.severityLevel;
    XCTAssertTrue(actual == expected);
}

- (void)testPropertiesPropertyWorksAsExpected {
    MSAIExceptionData *item = [MSAIExceptionData new];
    MSAIOrderedDictionary *actual = (MSAIOrderedDictionary *)item.properties;
    XCTAssertNotNil(actual, @"Pass");
}

- (void)testMeasurementsPropertyWorksAsExpected {
    MSAIExceptionData *item = [MSAIExceptionData new];
    MSAIOrderedDictionary *actual = (MSAIOrderedDictionary *)item.measurements;
    XCTAssertNotNil(actual, @"Pass");
}

- (void)testSerialize {
    MSAIExceptionData *item = [MSAIExceptionData new];
    item.version = @42;
    item.handledAt = @"Test string";
    NSArray *arrexceptions = @[[MSAIExceptionDetails new]];
    for (MSAIExceptionDetails *arrItem in arrexceptions) {
        [item.exceptions addObject:arrItem];
    }
    item.severityLevel = 5;
    item.properties = [MSAIOrderedDictionary dictionaryWithObjectsAndKeys: @"test value 1", @"key1", @"test value 2", @"key2", nil];
    MSAIOrderedDictionary *dictmeasurements = [MSAIOrderedDictionary dictionaryWithObjectsAndKeys:@3.1415, @"key1", @42.2, @"key2", nil];
    for (id key in dictmeasurements) {
        [item.measurements setObject:[dictmeasurements objectForKey:key]  forKey:key];
    }
    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"ver\":42,\"handledAt\":\"Test string\",\"exceptions\":[{\"hasFullStack\":true,\"parsedStack\":[]}],\"severityLevel\":5,\"properties\":{\"key1\":\"test value 1\",\"key2\":\"test value 2\"},\"measurements\":{\"key1\":3.1415,\"key2\":42.2}}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
