#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "AppInsights.h"
#import "AppInsightsPrivate.h"
#import "MSAIAppClient.h"
#import "MSAITelemetryManager.h"
#import "MSAITelemetryManagerPrivate.h"

static NSNotificationCenter *mockNotificationCenter = nil;

@implementation NSNotificationCenter (UnitTests)

+(id)defaultCenter {
  return mockNotificationCenter;
}

@end

@interface MSAITelemetryManagerTests : XCTestCase

@property (strong) MSAITelemetryManager *sut;

@end


@implementation MSAITelemetryManagerTests

- (void)setUp {
  [super setUp];
  
  self.sut = [MSAITelemetryManager new];
}

#pragma mark - Singleton Tests

- (void)testSharedManagerCreated {
  XCTAssertNotNil([MSAITelemetryManager sharedManager]);
}

- (void)testUniqueInstanceCreated {
  XCTAssertNotNil([MSAITelemetryManager new]);
}

- (void)testSingletonReturnsSameInstanceTwice {
  MSAITelemetryManager *m1 = [MSAITelemetryManager sharedManager];
  XCTAssertEqualObjects(m1, [MSAITelemetryManager sharedManager]);
}

- (void)testSingletonSeperateFromUniqueInstance {
  XCTAssertNotEqualObjects([MSAITelemetryManager sharedManager], [MSAITelemetryManager new]);
}

- (void)testTelemetryManagerReturnsSeperateUniqueInstances {
  XCTAssertNotEqualObjects([MSAITelemetryManager new], [MSAITelemetryManager new]);
}

- (void)testTelemetryEventQueueWasInitialised {
  XCTAssertNotNil(self.sut.telemetryEventQueue);
}

- (void)testManagerIsInitialised {
  XCTAssertFalse(self.sut.managerInitialised);
  [self.sut startManager];
  XCTAssertTrue(self.sut.managerInitialised);
}

- (void)testTelemetryManagerDisabled {
  XCTAssertFalse(self.sut.telemetryManagerDisabled);
  self.sut.telemetryManagerDisabled= YES;
  [self.sut startManager];
  XCTAssertFalse(self.sut.managerInitialised);
}

- (void)testRegisterObservers {
  mockNotificationCenter = mock(NSNotificationCenter.class);
  [self.sut registerObservers];
  [verifyCount(mockNotificationCenter, times(4)) addObserverForName:(id)anything() object:nil queue:NSOperationQueue.mainQueue usingBlock:(id)anything()];
}

@end
