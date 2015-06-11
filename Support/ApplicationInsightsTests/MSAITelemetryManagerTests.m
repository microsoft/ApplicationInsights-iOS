#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#import "ApplicationInsights.h"
#import "ApplicationInsightsPrivate.h"
#import "MSAIAppClient.h"
#import "MSAITelemetryManager.h"
#import "MSAITelemetryManagerPrivate.h"
#import "MSAITestsDependencyInjection.h"
#import "MSAIContextHelperPrivate.h"

@interface MSAITelemetryManagerTests : MSAITestsDependencyInjection

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
  // Instance already gets registered in init(). We have to unregister again, since we can't register twice.
  [self.sut unregisterObservers];
  
  [self.sut registerObservers];
  OCMVerify([self.mockNotificationCenter addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:[OCMArg any]]);
  OCMVerify([self.mockNotificationCenter addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:[OCMArg any]]);
  OCMVerify([self.mockNotificationCenter addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:[OCMArg any]]);
  OCMVerify([self.mockNotificationCenter addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:[OCMArg any]]);
  OCMVerify([self.mockNotificationCenter addObserverForName:MSAISessionStartedNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:[OCMArg any]]);
  OCMVerify([self.mockNotificationCenter addObserverForName:MSAISessionEndedNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:[OCMArg any]]);
  OCMVerify([self.mockNotificationCenter addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:[OCMArg any]]);
}

- (void)testTrackOrientationChange {
  self.sut = OCMPartialMock([MSAITelemetryManager new]);

  [self.sut trackCurrentOrientation];
  
  OCMVerify([self.sut trackEventWithName:[OCMArg isEqual:@"Device orientation changed"] properties:[OCMArg any]]);
}

@end
