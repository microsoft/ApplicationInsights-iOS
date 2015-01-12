//
//  TelemetryClientTest.m
//  applicationinsights
//
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TelemetryClient.h"

@interface TelemetryClientTest : XCTestCase

@end

@implementation TelemetryClientTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTrackTrace
{
    TelemetryClient *client = [[TelemetryClient alloc] init];
    [client trackTrace:@"test"];
    XCTAssert(YES, @"Pass");
}

@end
