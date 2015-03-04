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
    MSAIPersistence *_sut;
}

- (void)setUp {
  [super setUp];
  [MSAIAppInsights setup];
  [MSAIAppInsights start];
  _sut = [MSAIPersistence sharedInstance];
  _sut.maxFileCount = 20;
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
  
  //Delete all bundles to make sure we have a clean dir next time
  [_sut.requestedBundlePaths removeAllObjects];
  NSString *nextPath = [_sut requestNextPath];
  NSArray *bundle = [_sut bundleAtPath:nextPath];
  while (bundle) {
    [_sut deleteBundleAtPath:nextPath];
    nextPath = [_sut requestNextPath];
    bundle = [_sut bundleAtPath:nextPath];
  }
}

- (void)testNoBundles {
  XCTAssertNil([_sut requestNextPath]);
}

- (void)testIfItPersistsRegular {
  MSAIEnvelope *env = mock(MSAIEnvelope.class);
  [_sut persistBundle:@[env] ofType:MSAIPersistenceTypeRegular withCompletionBlock:^(BOOL success){
    XCTAssertTrue(success);
  }];
}

- (void)testReturnsSomething {
  MSAIEnvelope *env = mock(MSAIEnvelope.class);
  [_sut persistBundle:@[env] ofType:MSAIPersistenceTypeRegular withCompletionBlock:^(BOOL success){
    XCTAssertTrue(success);
  }];
}

- (void)testReturnsHighPrioFirst {
  NSString *testHigh = @"Test1";
  NSString *testRegular = @"Test2";
  
  [_sut persistBundle:@[testHigh] ofType:MSAIPersistenceTypeHighPriority withCompletionBlock:nil];
  [_sut persistBundle:@[testRegular] ofType:MSAIPersistenceTypeRegular withCompletionBlock:nil];
  
  NSString *nextPath = [_sut requestNextPath];
  NSString *returned = [[_sut bundleAtPath:nextPath] firstObject];
  XCTAssertTrue([returned isEqualToString:testHigh]);
  [_sut deleteBundleAtPath:nextPath];
  nextPath = [_sut requestNextPath];
  returned = [[_sut bundleAtPath:nextPath] firstObject];
  XCTAssertTrue([returned isEqualToString:testRegular]);
}

- (void)testDeletionWorks {
  MSAIEnvelope *env = mock(MSAIEnvelope.class);
  [_sut persistBundle:@[env] ofType:MSAIPersistenceTypeRegular withCompletionBlock:^(BOOL success){
    XCTAssertTrue(success);
  }];
  
  NSString *nextPath = [_sut requestNextPath];
  XCTAssertNotNil([_sut bundleAtPath:nextPath]);
 
  [_sut deleteBundleAtPath:nextPath];
  XCTAssertNil([_sut requestNextPath]);
}

- (void)testNextPathNotEmptyWhenFilePersisted{
  NSString *nextPath = [_sut requestNextPath];
  XCTAssertNil(nextPath);
  
  [self createFile];
  nextPath = [_sut requestNextPath];
  XCTAssertNotNil(nextPath);
}

- (void)testBundleForPathReturnsCorrectFile{
  NSString *bundleItemValue = @"myBundleItemValue";
  [_sut persistBundle:@[bundleItemValue] ofType:MSAIPersistenceTypeRegular withCompletionBlock:nil];
  NSString *nextPath = [_sut requestNextPath];
  NSArray *bundle = [_sut bundleAtPath:nextPath];
  
  XCTAssert([[bundle firstObject] isEqualToString:bundleItemValue]);
}

- (void)testIfIsFreeSpaceAvailableWorks{
  
  // Max 1 file at a time, we currently have 0
  _sut.maxFileCount = 1;
  XCTAssertTrue([_sut isFreeSpaceAvailable]);
  
  // Save a file, so we will reach the max count
  [self createFile];
  XCTAssertFalse([_sut isFreeSpaceAvailable]);
}

- (void)testRequestedPathIsBlocked{
  
  // Create file, make sure it has not been requested yet
  [self createFile];
  XCTAssertTrue(_sut.requestedBundlePaths.count == 0);
  
  // Path is added to list after path was requested
  NSString *path = [_sut requestNextPath];
  XCTAssertTrue(_sut.requestedBundlePaths.count == 1);
  XCTAssertEqual(_sut.requestedBundlePaths[0], path);
}

- (void)testRequestedPathIsReleasedWhenOnGiveBack{
  [self createFile];
  
  // Request path for sending
  NSString *path = [_sut requestNextPath];
  XCTAssertTrue(_sut.requestedBundlePaths.count == 1);
  
  // Release path again (e.g. no connection)
  [_sut giveBackRequestedPath:path];
  XCTAssertTrue(_sut.requestedBundlePaths.count == 0);
}

- (void)testRequestedPathIsReleasedOnDeletion {
  [self createFile];
  
  // Request path for sending
  NSString *path = [_sut requestNextPath];
  XCTAssertTrue(_sut.requestedBundlePaths.count == 1);
  
  // Release path again (e.g. successfully sent)
  [_sut deleteBundleAtPath:path];
  XCTAssertTrue(_sut.requestedBundlePaths.count == 0);
}

#pragma mark - Helper

-(void)createFile{
    [_sut persistBundle:@[@"testBundle"] ofType:MSAIPersistenceTypeRegular withCompletionBlock:nil];
}

@end
