#import <XCTest/XCTest.h>
#import "MSAIExceptionDetails.h"
#import "MSAIStackFrame.h"

@interface MSAIExceptionDetailsTests : XCTestCase

@end

@implementation MSAIExceptionDetailsTests

- (void)testidPropertyWorksAsExpected {
  NSNumber *expected;
  expected = @42;
    MSAIExceptionDetails *item = [MSAIExceptionDetails new];
    item.exceptionDetailsId = expected;
    NSNumber *actual = item.exceptionDetailsId;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = @13;
    item.exceptionDetailsId = expected;
    actual = item.exceptionDetailsId;
    XCTAssertTrue([actual isEqual:expected]);
}

- (void)testouter_idPropertyWorksAsExpected {
    NSNumber *expected = @42;
    MSAIExceptionDetails *item = [MSAIExceptionDetails new];
    item.outerId = expected;
    NSNumber *actual = item.outerId;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = @13;
    item.outerId = expected;
    actual = item.outerId;
    XCTAssertTrue([actual isEqual:expected]);
}

- (void)testtype_namePropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIExceptionDetails *item = [MSAIExceptionDetails new];
    item.typeName = expected;
    NSString *actual = item.typeName;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.typeName = expected;
    actual = item.typeName;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testmessagePropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIExceptionDetails *item = [MSAIExceptionDetails new];
    item.message = expected;
    NSString *actual = item.message;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.message = expected;
    actual = item.message;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testhas_full_stackPropertyWorksAsExpected {
    BOOL expected = YES;
    MSAIExceptionDetails *item = [MSAIExceptionDetails new];
    item.hasFullStack = expected;
    BOOL actual = item.hasFullStack;
    XCTAssertTrue(actual == expected);
    
    expected = NO;
    item.hasFullStack = expected;
    actual = item.hasFullStack;
    XCTAssertTrue(actual == expected);
}

- (void)teststackPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIExceptionDetails *item = [MSAIExceptionDetails new];
    item.stack = expected;
    NSString *actual = item.stack;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.stack = expected;
    actual = item.stack;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testParsed_stackPropertyWorksAsExpected {
    MSAIExceptionDetails *item = [MSAIExceptionDetails new];
    NSMutableArray *actual = (NSMutableArray *)item.parsedStack;
    XCTAssertNotNil(actual, @"Pass");
}

- (void)testSerialize {
    MSAIExceptionDetails *item = [MSAIExceptionDetails new];
    item.exceptionDetailsId = @42;
    item.outerId = @42;
    item.typeName = @"Test string";
    item.message = @"Test string";
    item.hasFullStack = YES;
    item.stack = @"Test string";
    NSArray *arrparsedStack = @[[MSAIStackFrame new]];
    for (MSAIStackFrame *arrItem in arrparsedStack) {
        [item.parsedStack addObject:arrItem];
    }
    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"id\":42,\"outerId\":42,\"typeName\":\"Test string\",\"message\":\"Test string\",\"hasFullStack\":true,\"stack\":\"Test string\",\"parsedStack\":[{}]}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
