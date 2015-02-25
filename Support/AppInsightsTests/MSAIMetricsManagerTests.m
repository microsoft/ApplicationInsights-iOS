#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "AppInsights.h"
#import "AppInsightsPrivate.h"
#import "MSAIAppClient.h"
#import "MSAIMetricsManager.h"
#import "MSAIMetricsManagerPrivate.h"

static NSNotificationCenter *mockNotificationCenter = nil;

@implementation NSNotificationCenter (UnitTests)

+(id)defaultCenter {
  return mockNotificationCenter;
}

@end

@interface MSAIMetricsManagerTests : XCTestCase

@property (strong) MSAIMetricsManager *sut;

@end


@implementation MSAIMetricsManagerTests

- (void)setUp {
  [super setUp];
  
  self.sut = [MSAIMetricsManager new];
}

#pragma mark - Singleton Tests

- (void)testSharedManagerCreated {
  XCTAssertNotNil([MSAIMetricsManager sharedManager]);
}

- (void)testUniqueInstanceCreated {
  XCTAssertNotNil([MSAIMetricsManager new]);
}

- (void)testSingletonReturnsSameInstanceTwice {
  MSAIMetricsManager *m1 = [MSAIMetricsManager sharedManager];
  XCTAssertEqualObjects(m1, [MSAIMetricsManager sharedManager]);
}

- (void)testSingletonSeperateFromUniqueInstance {
  XCTAssertNotEqualObjects([MSAIMetricsManager sharedManager], [MSAIMetricsManager new]);
}

- (void)testMetricsManagerReturnsSeperateUniqueInstances {
  XCTAssertNotEqualObjects([MSAIMetricsManager new], [MSAIMetricsManager new]);
}

- (void)testMetricsEventQueueWasInitialised {
  XCTAssertNotNil(self.sut.metricEventQueue);
}

- (void)testManagerIsInitialised {
  XCTAssertFalse(self.sut.managerInitialised);
  [self.sut startManager];
  XCTAssertTrue(self.sut.managerInitialised);
}

- (void)testMetricsManagerDisabled {
  XCTAssertFalse(self.sut.metricsManagerDisabled);
  self.sut.metricsManagerDisabled = YES;
  [self.sut startManager];
  XCTAssertFalse(self.sut.managerInitialised);
}

- (void)testRegisterObservers {
  mockNotificationCenter = mock(NSNotificationCenter.class);
  [self.sut registerObservers];
  [verifyCount(mockNotificationCenter, times(4)) addObserverForName:(id)anything() object:nil queue:NSOperationQueue.mainQueue usingBlock:(id)anything()];
}

@end
