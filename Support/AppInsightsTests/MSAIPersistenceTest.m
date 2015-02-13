#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "MSAIEnvelope.h"
#import "MSAIPersistence.h"

typedef void (^MSAIPersistenceTestBlock)(BOOL);

@interface MSAIPersistenceTest : XCTestCase

@end

@implementation MSAIPersistenceTest {
  

}

- (void)setUp {
    [super setUp];
  
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
  
  //Delete all bundles to make sure we have a clean dir next time
  NSArray *bundle = [MSAIPersistence nextBundle];
  while (bundle) {
    bundle = [MSAIPersistence nextBundle];
  }
}

- (void)testNoBundles {
  XCTAssertNil([MSAIPersistence nextBundle]);
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
  
  NSString *returned = [[MSAIPersistence nextBundle] firstObject];
  XCTAssertTrue([returned isEqualToString:testHigh]);
  returned = [[MSAIPersistence nextBundle] firstObject];
  XCTAssertTrue([returned isEqualToString:testRegular]);
}

- (void)testDeletionWorks {
  MSAIEnvelope *env = mock(MSAIEnvelope.class);
  [MSAIPersistence persistBundle:@[env] ofType:MSAIPersistenceTypeRegular withCompletionBlock:^(BOOL success){
    XCTAssertTrue(success);
  }];

  [MSAIPersistence nextBundle];
  XCTAssertNil([MSAIPersistence nextBundle]);
}

@end
