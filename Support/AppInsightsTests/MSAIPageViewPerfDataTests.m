#import <XCTest/XCTest.h>
#import "MSAIPageViewPerfData.h"

@interface MSAIPageViewPerfDataTests : XCTestCase

@end

@implementation MSAIPageViewPerfDataTests

- (void)testperf_totalPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIPageViewPerfData *item = [MSAIPageViewPerfData new];
    item.perfTotal = expected;
    NSString *actual = item.perfTotal;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.perfTotal = expected;
    actual = item.perfTotal;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testnetwork_connectPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIPageViewPerfData *item = [MSAIPageViewPerfData new];
    item.networkConnect = expected;
    NSString *actual = item.networkConnect;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.networkConnect = expected;
    actual = item.networkConnect;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testsent_requestPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIPageViewPerfData *item = [MSAIPageViewPerfData new];
    item.sentRequest = expected;
    NSString *actual = item.sentRequest;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.sentRequest = expected;
    actual = item.sentRequest;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testreceived_responsePropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIPageViewPerfData *item = [MSAIPageViewPerfData new];
    item.receivedResponse = expected;
    NSString *actual = item.receivedResponse;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.receivedResponse = expected;
    actual = item.receivedResponse;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testdom_processingPropertyWorksAsExpected {
    NSString *expected = @"Test string";
    MSAIPageViewPerfData *item = [MSAIPageViewPerfData new];
    item.domProcessing = expected;
    NSString *actual = item.domProcessing;
    XCTAssertTrue([actual isEqualToString:expected]);
    
    expected = @"Other string";
    item.domProcessing = expected;
    actual = item.domProcessing;
    XCTAssertTrue([actual isEqualToString:expected]);
}

- (void)testSerialize {
    MSAIPageViewPerfData *item = [MSAIPageViewPerfData new];
    item.perfTotal = @"Test string";
    item.networkConnect = @"Test string";
    item.sentRequest = @"Test string";
    item.receivedResponse = @"Test string";
    item.domProcessing = @"Test string";
    NSString *actual = [item serializeToString];
    NSString *expected = @"{\"ver\":2,\"properties\":{},\"measurements\":{},\"perfTotal\":\"Test string\",\"networkConnect\":\"Test string\",\"sentRequest\":\"Test string\",\"receivedResponse\":\"Test string\",\"domProcessing\":\"Test string\"}";
    XCTAssertTrue([actual isEqualToString:expected]);
}

@end
