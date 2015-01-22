@import XCTest;
#import "MSAIExceptionData.h"

@interface MSAIExceptionDataTests : XCTestCase

@end

@implementation MSAIExceptionDataTests

- (void)testverPropertyWorksAsExpected {
    NSNumber *expected = [NSNumber numberWithInt:42];
    MSAIExceptionData *item = [MSAIExceptionData new];
    item.version = expected;
    NSNumber *actual = item.version;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = [NSNumber numberWithInt:13];
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
    item.version = [NSNumber numberWithInt:42];
    item.handledAt = @"Test string";
    NSArray *arrexceptions = [NSArray arrayWithObjects: [MSAIExceptionDetails new], nil];
    for (MSAIExceptionDetails *arrItem in arrexceptions) {
        [item.exceptions addObject:arrItem];
    }
    item.severityLevel = 5;
    MSAIOrderedDictionary *dictproperties = [MSAIOrderedDictionary dictionaryWithObjectsAndKeys: @"test value 1", @"key1", @"test value 2", @"key2", nil];
    for (id key in dictproperties) {
        [item.properties setObject:[dictproperties objectForKey:key]  forKey:key];
    }
    MSAIOrderedDictionary *dictmeasurements = [MSAIOrderedDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithDouble:3.1415], @"key1", [NSNumber numberWithDouble:42.2], @"key2", nil];
    for (id key in dictmeasurements) {
        [item.measurements setObject:[dictmeasurements objectForKey:key]  forKey:key];
    }
    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"ver\":42,\"handledAt\":\"Test string\",\"exceptions\":[{\"hasFullStack\":true,\"parsedStack\":[]}],\"severityLevel\":5,\"properties\":{\"key1\":\"test value 1\",\"key2\":\"test value 2\"},\"measurements\":{\"key1\":3.1415,\"key2\":42.2}}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
