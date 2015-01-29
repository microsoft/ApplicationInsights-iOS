#import <XCTest/XCTest.h>
#import "MSAIBase.h"

@interface MSAIBaseTests : XCTestCase

@end

@implementation MSAIBaseTests

- (void)testbase_typePropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIBase *item = [MSAIBase new];
    item.baseType = expected;
    NSString *actual = item.baseType;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.baseType = expected;
    actual = item.baseType;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testSerialize {
    MSAIBase *item = [MSAIBase new];
    item.baseType = @"Test string";
    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"baseType\":\"Test string\"}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
