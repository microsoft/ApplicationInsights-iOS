#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "MSAISession.h"
#import "MSAISessionHelper.h"
#import "MSAISessionHelperPrivate.h"
#import "MSAIPersistence.h"
#import "MSAIPersistencePrivate.h"
#import "MSAITestsDependencyInjection.h"

@interface MSAISessionHelperTests : MSAITestsDependencyInjection

@property (strong) MSAISessionHelper *sut;

@end

@implementation MSAISessionHelperTests {
  MSAIPersistence *_persistence;
}

- (void)setUp {
  [super setUp];
  
  self.sut = [MSAISessionHelper new];
  self.sut.sessionEntries = [NSMutableDictionary new];
  assertThatInteger(_sut.sessionEntries.count, equalToInteger(0));
}

- (void)teardown {
  NSString *path = [[MSAIPersistence sharedInstance] newFileURLForPersitenceType:MSAIPersistenceTypeSessionIds];
  [[MSAIPersistence sharedInstance] deleteFileAtPath:path];
  
  [super tearDown];
}

#pragma mark - Setup Tests

- (void)testAddSessionWorks {
  
  NSDate *date = [NSDate date];
  NSString *timestamp = [self.sut unixTimestampFromDate:date];
  MSAISession *session = [self sessionWithId:@"4815162342"];
  
  [self.sut addSession:session withDate:date];
  
  XCTAssertEqual(self.sut.sessionEntries.count, 1);
  XCTAssertEqualObjects(self.sut.sessionEntries[timestamp], session);
}

- (void)testRemoveSessionWorks {
  MSAISession *sessionA = [self sessionWithId:@"a"];
  MSAISession *sessionB = [self sessionWithId:@"b"];
  MSAISession *sessionC = [self sessionWithId:@"c"];
  
  [self.sut addSession:sessionA withDate:[NSDate dateWithTimeIntervalSince1970:0]];
  [self.sut addSession:sessionB withDate:[NSDate dateWithTimeIntervalSince1970:1]];
  [self.sut addSession:sessionC withDate:[NSDate dateWithTimeIntervalSince1970:2]];
  
  [self.sut removeSession:[self sessionWithId:@"b"]];
  
  XCTAssertLessThanOrEqual(self.sut.sessionEntries.count, 2);
  XCTAssertNotNil(self.sut.sessionEntries[@"0"]);
  XCTAssertNotNil(self.sut.sessionEntries[@"2"]);
  XCTAssertNil(self.sut.sessionEntries[@"1"]);
  
}

- (void)testCleanUpSessionsWorks {
  XCTAssertEqual(self.sut.sessionEntries.count, 0);
  
  MSAISession *sessionA = [self sessionWithId:@"a"];
  MSAISession *sessionB = [self sessionWithId:@"b"];
  MSAISession *sessionC = [self sessionWithId:@"c"];
  
  [self.sut addSession:sessionA withDate:[NSDate dateWithTimeIntervalSince1970:3]];
  [self.sut addSession:sessionB withDate:[NSDate dateWithTimeIntervalSince1970:33]];
  [self.sut addSession:sessionC withDate:[NSDate dateWithTimeIntervalSince1970:333]];
  XCTAssertEqual(self.sut.sessionEntries.count, 3);
  
  [self.sut cleanUpSessions];
  
  XCTAssertLessThanOrEqual(self.sut.sessionEntries.count, 1);
  
  XCTAssertNil(self.sut.sessionEntries[@"3"]);
  XCTAssertNil(self.sut.sessionEntries[@"33"]);
  XCTAssertEqualObjects(self.sut.sessionEntries[@"333"], sessionC);
}

- (void)testReturnsCorrectSessionForDate {
  MSAISession *session1 = [self sessionWithId:@"10"];
  MSAISession *session2 = [self sessionWithId:@"20"];
  MSAISession *session3 = [self sessionWithId:@"30"];
  
  [self.sut addSession:session1 withDate:[NSDate dateWithTimeIntervalSince1970:3]];
  [self.sut addSession:session2 withDate:[NSDate dateWithTimeIntervalSince1970:33]];
  [self.sut addSession:session3 withDate:[NSDate dateWithTimeIntervalSince1970:333]];
  
  MSAISession *session = [self.sut sessionForDate:[NSDate dateWithTimeIntervalSince1970:0]];
  XCTAssertNil(session);
  
  session = [self.sut sessionForDate:[NSDate dateWithTimeIntervalSince1970:3]];
  XCTAssertNil(session);
  
  session = [self.sut sessionForDate:[NSDate dateWithTimeIntervalSince1970:3+23]];
  XCTAssertEqual(session, session1);
  
  session = [self.sut sessionForDate:[NSDate dateWithTimeIntervalSince1970:33]];
  XCTAssertEqual(session, session1);
  
  session = [self.sut sessionForDate:[NSDate dateWithTimeIntervalSince1970:33+42]];
  XCTAssertEqual(session, session2);
  
  session = [self.sut sessionForDate:[NSDate dateWithTimeIntervalSince1970:333+1337]];
  XCTAssertEqual(session, session3);
  
}

- (void)testUnixTimestampFromDate {
  NSString *timestamp = [self.sut unixTimestampFromDate:[NSDate dateWithTimeIntervalSince1970:42]];
  XCTAssertEqualObjects(timestamp, @"42");
}

- (void)testRegisterObserversOnInit {

  [verifyCount(self.mockNotificationCenter, times(3)) addObserverForName:(id)anything() object:nil queue:NSOperationQueue.mainQueue usingBlock:(id)anything()];
}

- (void)testSessionHelperNotifications {
  [self setMockNotificationCenter:[NSNotificationCenter new]];
  
  [self.sut registerObservers];
  
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UIApplicationDidEnterBackgroundNotification object:nil]];
  
  // Add partial mock of session helper here
}

#pragma mark Helper

- (MSAISession *)sessionWithId:(NSString *)sessionId {
  MSAISession *session = [MSAISession new];
  session.sessionId = sessionId;
  session.isNew = @"false";
  session.isFirst = @"false";
  
  return session;
}

@end
