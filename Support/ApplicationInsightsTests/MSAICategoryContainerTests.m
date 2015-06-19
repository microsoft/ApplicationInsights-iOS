#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MSAITelemetryManager.h"
#import "MSAICategoryContainer.h"

@interface MSAICategoryContainerTests : XCTestCase

@property (nonatomic, strong) MSAICategoryContainer *sut;

@end

@implementation MSAICategoryContainerTests

- (void)setUp {
  [super setUp];
  self.sut = [MSAICategoryContainer new];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testmsai_viewWillAppear {
  UIViewController *vc = [UIViewController new];
  [MSAICategoryContainer activateCategory];
  
  NSString *className = NSStringFromClass([vc class]);
  
  id mockTelemetryManager = OCMClassMock([MSAITelemetryManager class]);
  [[[mockTelemetryManager stub] andReturn:mockTelemetryManager] sharedManager];
  OCMExpect([mockTelemetryManager trackPageView:className]);
  
  [vc viewWillAppear:NO];
  
  OCMVerifyAll(mockTelemetryManager);
  [mockTelemetryManager stopMocking];
}

- (void)testShouldTrackPageView {
  BOOL shouldTrack;
  
  shouldTrack = msai_shouldTrackPageView([UIViewController new]);
  XCTAssertTrue(shouldTrack);
  
  shouldTrack = msai_shouldTrackPageView([UINavigationController new]);
  XCTAssertFalse(shouldTrack);
  
  shouldTrack = msai_shouldTrackPageView([UITabBarController new]);
  XCTAssertFalse(shouldTrack);
  if ([UIDevice currentDevice].orientation == UIUserInterfaceIdiomPad) {
    shouldTrack = msai_shouldTrackPageView([UISplitViewController new]);
    XCTAssertFalse(shouldTrack);
  }
  
//  shouldTrack = msai_shouldTrackPageView([UIInputWindowController new]);
//  XCTAssertFalse(shouldTrack);
  
  shouldTrack = msai_shouldTrackPageView([UIPageViewController new]);
  XCTAssertFalse(shouldTrack);
}

- (void)testPageViewNameForViewController {
  NSString *pageViewName = @"";
  NSString *testTitle = @"TestTitle";
  
  UINavigationController *testViewController = [UINavigationController new];
  testViewController.title = testTitle;
  
  pageViewName = msai_pageViewNameForViewController(testViewController);
  
  XCTAssertEqualObjects(pageViewName, @"UINavigationController TestTitle");
  
  
  testViewController = [UINavigationController new];
  
  pageViewName = msai_pageViewNameForViewController(testViewController);
  
  XCTAssertEqualObjects(pageViewName, @"UINavigationController");
}

@end
