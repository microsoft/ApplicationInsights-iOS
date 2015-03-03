#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "AppInsights.h"
#import "MSAIEnvelope.h"
#import "MSAIPersistence.h"

typedef void (^MSAIPersistenceTestBlock)(BOOL);

@interface MSAIPersistenceTest : XCTestCase

@end

@implementation MSAIPersistenceTest {
  
}

- (void)setUp {
  [super setUp];
  [MSAIAppInsights setup];
  [MSAIAppInsights start];
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
  
  //Delete all bundles to make sure we have a clean dir next time
  NSString *nextPath = [MSAIPersistence nextPath];
  NSArray *bundle = [MSAIPersistence bundleAtPath:nextPath];
  while (bundle) {
    [MSAIPersistence deleteBundleAtPath:nextPath];
    nextPath = [MSAIPersistence nextPath];
    bundle = [MSAIPersistence bundleAtPath:nextPath];
  }
}

- (void)testNoBundles {
  XCTAssertNil([MSAIPersistence nextPath]);
}

- (void)testIfItPersistsRegular {
  MSAIEnvelope *env = mock(MSAIEnvelope.class);
  [MSAIPersistence persistBundle:@[env] ofType:MSAIPersistenceTypeRegular withCompletionBlock:^(BOOL success){
    XCTAssertTrue(success);
  }];
}

- (void)testReturnsSomething {
  MSAIEnvelope *env = mock(MSAIEnvelope.class);
  [MSAIPersistence persistBundle:@[env] ofType:MSAIPersistenceTypeRegular withCompletionBlock:^(BOOL success){
    XCTAssertTrue(success);
  }];
}

- (void)testReturnsHighPrioFirst {
  NSString *testHigh = @"Test1";
  NSString *testRegular = @"Test2";
  
  [MSAIPersistence persistBundle:@[testHigh] ofType:MSAIPersistenceTypeHighPriority withCompletionBlock:nil];
  [MSAIPersistence persistBundle:@[testRegular] ofType:MSAIPersistenceTypeRegular withCompletionBlock:nil];
  
  NSString *nextPath = [MSAIPersistence nextPath];
  NSString *returned = [[MSAIPersistence bundleAtPath:nextPath] firstObject];
  XCTAssertTrue([returned isEqualToString:testHigh]);
  [MSAIPersistence deleteBundleAtPath:nextPath];
  nextPath = [MSAIPersistence nextPath];
  returned = [[MSAIPersistence bundleAtPath:nextPath] firstObject];
  XCTAssertTrue([returned isEqualToString:testRegular]);
}

- (void)testDeletionWorks {
  MSAIEnvelope *env = mock(MSAIEnvelope.class);
  [MSAIPersistence persistBundle:@[env] ofType:MSAIPersistenceTypeRegular withCompletionBlock:^(BOOL success){
    XCTAssertTrue(success);
  }];
  
  NSString *nextPath = [MSAIPersistence nextPath];
  XCTAssertNotNil([MSAIPersistence bundleAtPath:nextPath]);
 
  [MSAIPersistence deleteBundleAtPath:nextPath];
  XCTAssertNil([MSAIPersistence nextPath]);
}

@end
