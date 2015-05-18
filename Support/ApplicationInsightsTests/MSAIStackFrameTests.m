#import <XCTest/XCTest.h>
#import "MSAIStackFrame.h"

@interface MSAIStackFrameTests : XCTestCase

@end

@implementation MSAIStackFrameTests

- (void)testlevelPropertyWorksAsExpected {
  NSNumber *expected;
  expected = @42;
    MSAIStackFrame *item = [MSAIStackFrame new];
    item.level = expected;
    NSNumber *actual = item.level;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = @13;
    item.level = expected;
    actual = item.level;
    XCTAssertTrue([actual isEqual:expected]);
}

- (void)testmethodPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIStackFrame *item = [MSAIStackFrame new];
    item.method = expected;
    NSString *actual = item.method;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.method = expected;
    actual = item.method;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testassemblyPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIStackFrame *item = [MSAIStackFrame new];
    item.assembly = expected;
    NSString *actual = item.assembly;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.assembly = expected;
    actual = item.assembly;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testfile_namePropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIStackFrame *item = [MSAIStackFrame new];
    item.fileName = expected;
    NSString *actual = item.fileName;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.fileName = expected;
    actual = item.fileName;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testlinePropertyWorksAsExpected {
    NSNumber *expected = @42;
    MSAIStackFrame *item = [MSAIStackFrame new];
    item.line = expected;
    NSNumber *actual = item.line;
    XCTAssertTrue([actual isEqual:expected]);
    
    expected = @13;
    item.line = expected;
    actual = item.line;
    XCTAssertTrue([actual isEqual:expected]);
}

- (void)testSerialize {
    MSAIStackFrame *item = [MSAIStackFrame new];
    item.level = @42;
    item.method = @"Test string";
    item.assembly = @"Test string";
    item.fileName = @"Test string";
    item.line = @42;
    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"level\":42,\"method\":\"Test string\",\"assembly\":\"Test string\",\"fileName\":\"Test string\",\"line\":42}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
