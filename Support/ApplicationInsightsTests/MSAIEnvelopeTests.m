#import <XCTest/XCTest.h>
#import "MSAIEnvelope.h"
#import "MSAIOrderedDictionary.h"

@interface MSAIEnvelopeTests : XCTestCase

@end

@implementation MSAIEnvelopeTests

- (void)testverPropertyWorksAsExpected {
  NSNumber *expected = @42;
    MSAIEnvelope *item = [MSAIEnvelope new];
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
    MSAIEnvelope *item = [MSAIEnvelope new];
    item.name = expected;
    NSString *actual = item.name;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.name = expected;
    actual = item.name;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testtimePropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIEnvelope *item = [MSAIEnvelope new];
    item.time = expected;
    NSString *actual = item.time;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.time = expected;
    actual = item.time;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testsample_ratePropertyWorksAsExpected {
    NSNumber *expected = @1.5;
    MSAIEnvelope *item = [MSAIEnvelope new];
    item.sampleRate = expected;
    NSNumber *actual = item.sampleRate;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = @4.8;
    item.sampleRate = expected;
    actual = item.sampleRate;
    XCTAssertTrue([actual isEqual:expected]);
}

- (void)testseqPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIEnvelope *item = [MSAIEnvelope new];
    item.seq = expected;
    NSString *actual = item.seq;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.seq = expected;
    actual = item.seq;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testi_keyPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIEnvelope *item = [MSAIEnvelope new];
    item.iKey = expected;
    NSString *actual = item.iKey;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.iKey = expected;
    actual = item.iKey;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testflagsPropertyWorksAsExpected {
    NSNumber *expected = @42;
    MSAIEnvelope *item = [MSAIEnvelope new];
    item.flags = expected;
    NSNumber *actual = item.flags;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = @13;
    item.flags = expected;
    actual = item.flags;
    XCTAssertTrue([actual isEqual:expected]);
}

- (void)testdevice_idPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIEnvelope *item = [MSAIEnvelope new];
    item.deviceId = expected;
    NSString *actual = item.deviceId;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.deviceId = expected;
    actual = item.deviceId;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testosPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIEnvelope *item = [MSAIEnvelope new];
    item.os = expected;
    NSString *actual = item.os;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.os = expected;
    actual = item.os;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testos_verPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIEnvelope *item = [MSAIEnvelope new];
    item.osVer = expected;
    NSString *actual = item.osVer;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.osVer = expected;
    actual = item.osVer;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testapp_idPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIEnvelope *item = [MSAIEnvelope new];
    item.appId = expected;
    NSString *actual = item.appId;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.appId = expected;
    actual = item.appId;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testapp_verPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIEnvelope *item = [MSAIEnvelope new];
    item.appVer = expected;
    NSString *actual = item.appVer;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.appVer = expected;
    actual = item.appVer;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testuser_idPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIEnvelope *item = [MSAIEnvelope new];
    item.userId = expected;
    NSString *actual = item.userId;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.userId = expected;
    actual = item.userId;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testTagsPropertyWorksAsExpected {
    MSAIEnvelope *item = [MSAIEnvelope new];
    MSAIOrderedDictionary *actual = (MSAIOrderedDictionary *)item.tags;
    XCTAssertNotNil(actual, @"Pass");
}

- (void)testdataPropertyWorksAsExpected {
    MSAIBase *expected = [MSAIBase new];
    MSAIEnvelope *item = [MSAIEnvelope new];
    item.data = expected;
    MSAIBase *actual = item.data;
    XCTAssertTrue(actual == expected);
    
    expected = [MSAIBase new];
    item.data = expected;
    actual = item.data;
    XCTAssertTrue(actual == expected);
}

- (void)testSerialize {
    MSAIEnvelope *item = [MSAIEnvelope new];
    item.version = @42;
    item.name = @"Test string";
    item.time = @"Test string";
    item.sampleRate = @1.5;
    item.seq = @"Test string";
    item.iKey = @"Test string";
    item.flags = @42;
    item.deviceId = @"Test string";
    item.os = @"Test string";
    item.osVer = @"Test string";
    item.appId = @"Test string";
    item.appVer = @"Test string";
    item.userId = @"Test string";
    MSAIOrderedDictionary *dicttags = [MSAIOrderedDictionary dictionaryWithObjectsAndKeys: @"test value 1", @"key1", @"test value 2", @"key2", nil];
    for (id key in dicttags) {
        [item.tags setObject:[dicttags objectForKey:key]  forKey:key];
    }
    item.data = [MSAIBase new];
    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"ver\":42,\"name\":\"Test string\",\"time\":\"Test string\",\"sampleRate\":1.5,\"seq\":\"Test string\",\"iKey\":\"Test string\",\"flags\":42,\"deviceId\":\"Test string\",\"os\":\"Test string\",\"osVer\":\"Test string\",\"appId\":\"Test string\",\"appVer\":\"Test string\",\"userId\":\"Test string\",\"tags\":{\"key1\":\"test value 1\",\"key2\":\"test value 2\"},\"data\":{}}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
