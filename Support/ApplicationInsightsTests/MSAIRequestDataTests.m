#import <XCTest/XCTest.h>
#import "MSAIRequestData.h"
#import "MSAIOrderedDictionary.h"

@interface MSAIRequestDataTests : XCTestCase

@end

@implementation MSAIRequestDataTests

- (void)testverPropertyWorksAsExpected {
    NSNumber *expected = @42;
    MSAIRequestData *item = [MSAIRequestData new];
    item.version = expected;
    NSNumber *actual = item.version;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = @13;
    item.version = expected;
    actual = item.version;
    XCTAssertTrue([actual isEqual:expected]);
}

- (void)testidPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIRequestData *item = [MSAIRequestData new];
    item.requestDataId = expected;
    NSString *actual = item.requestDataId;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.requestDataId = expected;
    actual = item.requestDataId;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testnamePropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIRequestData *item = [MSAIRequestData new];
    item.name = expected;
    NSString *actual = item.name;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.name = expected;
    actual = item.name;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)teststart_timePropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIRequestData *item = [MSAIRequestData new];
    item.startTime = expected;
    NSString *actual = item.startTime;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.startTime = expected;
    actual = item.startTime;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testdurationPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIRequestData *item = [MSAIRequestData new];
    item.duration = expected;
    NSString *actual = item.duration;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.duration = expected;
    actual = item.duration;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testresponse_codePropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIRequestData *item = [MSAIRequestData new];
    item.responseCode = expected;
    NSString *actual = item.responseCode;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.responseCode = expected;
    actual = item.responseCode;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testsuccessPropertyWorksAsExpected {
    BOOL expected = YES;
    MSAIRequestData *item = [MSAIRequestData new];
    item.success = expected;
    BOOL actual = item.success;
    XCTAssertTrue(actual == expected);
    
    expected = NO;
    item.success = expected;
    actual = item.success;
    XCTAssertTrue(actual == expected);
}

- (void)testhttp_methodPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIRequestData *item = [MSAIRequestData new];
    item.httpMethod = expected;
    NSString *actual = item.httpMethod;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.httpMethod = expected;
    actual = item.httpMethod;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testurlPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIRequestData *item = [MSAIRequestData new];
    item.url = expected;
    NSString *actual = item.url;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.url = expected;
    actual = item.url;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testPropertiesPropertyWorksAsExpected {
    MSAIRequestData *item = [MSAIRequestData new];
    MSAIOrderedDictionary *actual = (MSAIOrderedDictionary *)item.properties;
    XCTAssertNotNil(actual, @"Pass");
}

- (void)testMeasurementsPropertyWorksAsExpected {
    MSAIRequestData *item = [MSAIRequestData new];
    MSAIOrderedDictionary *actual = (MSAIOrderedDictionary *)item.measurements;
    XCTAssertNotNil(actual, @"Pass");
}

- (void)testSerialize {
    MSAIRequestData *item = [MSAIRequestData new];
    item.version = @42;
    item.requestDataId = @"Test string";
    item.name = @"Test string";
    item.startTime = @"Test string";
    item.duration = @"Test string";
    item.responseCode = @"Test string";
    item.success = YES;
    item.httpMethod = @"Test string";
    item.url = @"Test string";
    item.properties = [MSAIOrderedDictionary dictionaryWithObjectsAndKeys: @"test value 1", @"key1", @"test value 2", @"key2", nil];

    MSAIOrderedDictionary *dictmeasurements = [MSAIOrderedDictionary dictionaryWithObjectsAndKeys:@3.1415, @"key1", @42.2, @"key2", nil];
    for (id key in dictmeasurements) {
        [item.measurements setObject:[dictmeasurements objectForKey:key]  forKey:key];
    }
    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"ver\":42,\"id\":\"Test string\",\"name\":\"Test string\",\"startTime\":\"Test string\",\"duration\":\"Test string\",\"responseCode\":\"Test string\",\"success\":true,\"httpMethod\":\"Test string\",\"url\":\"Test string\",\"properties\":{\"key1\":\"test value 1\",\"key2\":\"test value 2\"},\"measurements\":{\"key1\":3.1415,\"key2\":42.2}}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
