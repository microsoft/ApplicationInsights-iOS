#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
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

@end
