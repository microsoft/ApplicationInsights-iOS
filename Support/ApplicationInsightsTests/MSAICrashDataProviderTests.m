#import <XCTest/XCTest.h>
#import "MSAICrashDataProviderPrivate.h"
#import "MSAIStackFrame.h"
#import "ApplicationInsightsFeatureConfig.h"

@interface MSAICrashDataProviderTests : XCTestCase

@end

@implementation MSAICrashDataProviderTests

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown { 
  [super tearDown];
}

- (void) testParseSingleManagedStackframeFromStringWorks {
  // Setup
  NSString *testString1 = @"  at My.Method/Name (My.Parameter Type) in My/Filename:123 ";
  // Test
  MSAIStackFrame *frame1 = [MSAICrashDataProvider stackframeForStackLine:testString1];
  // Verify
  XCTAssertEqualObjects(@"My.Method/Name (My.Parameter Type)", frame1.method);
  XCTAssertEqualObjects(@"My/Filename", frame1.fileName);
  XCTAssertEqual(123, [frame1.line intValue]);
  
  // Setup
  NSString *testString2 = @"at  My.Method/Name(My.ParameterType) in My/Filename:noNumber ";
  // Test
  MSAIStackFrame *frame2 = [MSAICrashDataProvider stackframeForStackLine:testString2];
  // Verify
  
  XCTAssertEqualObjects(@"My.Method/Name(My.ParameterType)", frame2.method);
  XCTAssertNil(frame2.fileName);
  XCTAssertNil(frame2.line);
  
  // Setup
  NSString *testString3 = @"at SampleApp.Application.Main (System.String[] args) [0x00000] in <filename unknown>:0 ";
  // Test
  MSAIStackFrame *frame3 = [MSAICrashDataProvider stackframeForStackLine:testString3];
  // Verify
  XCTAssertEqualObjects(@"SampleApp.Application.Main (System.String[] args)", frame3.method);
  XCTAssertEqualObjects(@"<filename unknown>", frame3.fileName);
  XCTAssertNil(frame3.line);
  
  NSString *testString4 = @"  at (wrapper managed-to-native) UIKit.UIApplication:UIApplicationMain (int,string[],intptr,intptr) ";
  // Test
  MSAIStackFrame *frame4 = [MSAICrashDataProvider stackframeForStackLine:testString4];
  // Verify
  XCTAssertEqualObjects(@"(wrapper managed-to-native) UIKit.UIApplication:UIApplicationMain (int,string[],intptr,intptr)", frame4.method);
  XCTAssertNil(frame4.fileName);
  XCTAssertNil(frame4.line);
  
  NSString *testString5 = @"My.Method/Name(My.ParameterType) in My/Filename:123    ";
  // Test
  MSAIStackFrame *frame5 = [MSAICrashDataProvider stackframeForStackLine:testString5];
  // Verify
  XCTAssertNil(frame5);
}


@end
