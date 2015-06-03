#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "MSAISession.h"
#import "MSAIUser.h"
#import "MSAIContextHelper.h"
#import "MSAIContextHelperPrivate.h"
#import "MSAIPersistence.h"
#import "MSAIPersistencePrivate.h"
#import "MSAITestsDependencyInjection.h"

@interface MSAIContextHelperTests : MSAITestsDependencyInjection

@property (strong) MSAIContextHelper *sut;

@end

@implementation MSAIContextHelperTests

- (void)setUp {
  [super setUp];
  
  self.sut = [MSAIContextHelper new];
  self.sut.metaData[@"sessions"] = [NSMutableDictionary new];
  self.sut.metaData[@"users"] = [NSMutableDictionary new];
}

- (void)teardown {
  NSString *path = [[MSAIPersistence sharedInstance] newFileURLForPersitenceType:MSAIPersistenceTypeMetaData];
  [[MSAIPersistence sharedInstance] deleteFileAtPath:path];
  
  [super tearDown];
}

#pragma mark - Setup Tests

- (void)testSetupCorrectly {
  for (NSObject *object in self.sut.metaData.allValues) {
    assertThat(object, instanceOf(NSMutableDictionary.class));
  }
  assertThatInteger(_sut.metaData.count, equalToInteger(2));
}

#pragma mark - User Tests

- (void)testNewUser {
  MSAIUser *newUser = [self.sut newUser];
  XCTAssertNotNil(newUser);
  XCTAssertEqual(newUser.userId.length, 36U);
}

- (void)testNewUserWithId {
  MSAIUser *newUser = [self.sut newUserWithId:@"testId1"];
  XCTAssertNotNil(newUser);
  XCTAssertEqual(newUser.userId, @"testId1");
}

- (void)testSetCurrentUserId {
  NSString *testId = @"testId2";
  
  
  OCMExpect([self.mockNotificationCenter postNotificationName:MSAIUserIdChangedNotification object:self.sut userInfo:@{kMSAIUserInfoUserId: testId}]);
  
  [self.sut setCurrentUserId:testId];
  NSString *userId = [self.sut userForDate:[NSDate date]].userId;
  XCTAssertEqualObjects(userId, testId);
  
  [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
  
  OCMVerifyAll(self.mockNotificationCenter);
}

- (void)testAddUser {
  XCTAssert([self.sut.metaData[@"users"] count] == 0);
  MSAIUser *testUser = [MSAIUser new];
  [self.sut addUser:testUser forDate:[NSDate dateWithTimeIntervalSince1970:23]];
  XCTAssert([self.sut.metaData[@"users"] count] == 1);
  XCTAssertEqualObjects(testUser, self.sut.metaData[@"users"][@"23"]);
}

- (void)testUserForDate {
  MSAIUser *user1 = [self.sut newUserWithId:@"10"];
  MSAIUser *user2 = [self.sut newUserWithId:@"20"];
  MSAIUser *user3 = [self.sut newUserWithId:@"30"];
  
  [self.sut addUser:user1 forDate:[NSDate dateWithTimeIntervalSince1970:3]];
  [self.sut addUser:user2 forDate:[NSDate dateWithTimeIntervalSince1970:33]];
  [self.sut addUser:user3 forDate:[NSDate dateWithTimeIntervalSince1970:333]];
  
  MSAIUser *user = [self.sut userForDate:[NSDate dateWithTimeIntervalSince1970:0]];
  XCTAssertNil(user);
  
  user = [self.sut userForDate:[NSDate dateWithTimeIntervalSince1970:2]];
  XCTAssertNil(user);
  
  user = [self.sut userForDate:[NSDate dateWithTimeIntervalSince1970:3+23]];
  XCTAssertEqual(user, user1);
  
  user = [self.sut userForDate:[NSDate dateWithTimeIntervalSince1970:33]];
  XCTAssertEqual(user, user2);
  
  user = [self.sut userForDate:[NSDate dateWithTimeIntervalSince1970:33+42]];
  XCTAssertEqual(user, user2);
  
  user = [self.sut userForDate:[NSDate dateWithTimeIntervalSince1970:333+1337]];
  XCTAssertEqual(user, user3);
}

- (void)testRemoveUserId {
  MSAIUser *userA = [self.sut newUserWithId:@"a"];
  MSAIUser *userB = [self.sut newUserWithId:@"b"];
  MSAIUser *userC = [self.sut newUserWithId:@"c"];
  
  [self.sut addUser:userA forDate:[NSDate dateWithTimeIntervalSince1970:0]];
  [self.sut addUser:userB forDate:[NSDate dateWithTimeIntervalSince1970:1]];
  [self.sut addUser:userC forDate:[NSDate dateWithTimeIntervalSince1970:2]];
  
  [self.sut removeUserId:@"b"];
  
  XCTAssertEqual(self.sut.metaData.count, 2U);
  XCTAssertEqual([self.sut.metaData[@"users"] count], 2U);
  XCTAssertEqualObjects(self.sut.metaData[@"users"][@"0"], userA);
  XCTAssertEqualObjects(self.sut.metaData[@"users"][@"2"], userC);
  XCTAssertNil(self.sut.metaData[@"users"][@"1"]);
  
}

#pragma mark - Session Tests

#pragma mark Test Automtic Session Management

- (void)testRegisterObserversOnInit {
  self.mockNotificationCenter = mock(NSNotificationCenter.class);
  
  self.sut = [MSAIContextHelper new];
  
  [verify((id)self.mockNotificationCenter) addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:(id)anything()];
  [verify((id)self.mockNotificationCenter) addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:(id)anything()];
  [verify((id)self.mockNotificationCenter) addObserverForName:UIApplicationWillTerminateNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:(id)anything()];
}

#pragma mark Test Manual Session Management

- (void)testRenewSessionWithId {
  self.sut = OCMPartialMock(self.sut);
  XCTAssertEqual([self.sut.metaData[@"sessions"] count], 0U);
  
  NSString *testId = @"1337";
  [self.sut renewSessionWithId:testId];
  
  OCMVerify([self.sut sendSessionStartedNotificationWithUserInfo:[OCMArg checkWithBlock:^BOOL(NSDictionary *userInfo) {
    MSAISession *session = userInfo[kMSAISessionInfoSession];
    if ([session.sessionId isEqualToString:testId])  {
      return YES;
    }
    return NO;
  }]]);
}

- (void)testAddSession {
  NSDate *date = [NSDate date];
  NSString *timestamp = [self.sut unixTimestampFromDate:date];
  MSAISession *session = [self sessionWithId:@"4815162342"];
  
  [self.sut addSession:session withDate:date];
  
  XCTAssertEqual(((NSMutableDictionary *)self.sut.metaData[@"sessions"]).count, 1U);
  XCTAssertEqualObjects(self.sut.metaData[@"sessions"][timestamp], session);
}

- (void)testSessionForDate {
  MSAISession *session1 = [self sessionWithId:@"10"];
  MSAISession *session2 = [self sessionWithId:@"20"];
  MSAISession *session3 = [self sessionWithId:@"30"];
  
  [self.sut addSession:session1 withDate:[NSDate dateWithTimeIntervalSince1970:3]];
  [self.sut addSession:session2 withDate:[NSDate dateWithTimeIntervalSince1970:33]];
  [self.sut addSession:session3 withDate:[NSDate dateWithTimeIntervalSince1970:333]];
  
  MSAISession *session = [self.sut sessionForDate:[NSDate dateWithTimeIntervalSince1970:0]];
  XCTAssertNil(session);
  
  session = [self.sut sessionForDate:[NSDate dateWithTimeIntervalSince1970:2]];
  XCTAssertNil(session);
  
  session = [self.sut sessionForDate:[NSDate dateWithTimeIntervalSince1970:3+23]];
  XCTAssertEqual(session, session1);
  
  session = [self.sut sessionForDate:[NSDate dateWithTimeIntervalSince1970:33]];
  XCTAssertEqual(session, session2);
  
  session = [self.sut sessionForDate:[NSDate dateWithTimeIntervalSince1970:33+42]];
  XCTAssertEqual(session, session2);
  
  session = [self.sut sessionForDate:[NSDate dateWithTimeIntervalSince1970:333+1337]];
  XCTAssertEqual(session, session3);
}

- (void)testRemoveSession {
  MSAISession *sessionA = [self sessionWithId:@"a"];
  MSAISession *sessionB = [self sessionWithId:@"b"];
  MSAISession *sessionC = [self sessionWithId:@"c"];
  
  [self.sut addSession:sessionA withDate:[NSDate dateWithTimeIntervalSince1970:0]];
  [self.sut addSession:sessionB withDate:[NSDate dateWithTimeIntervalSince1970:1]];
  [self.sut addSession:sessionC withDate:[NSDate dateWithTimeIntervalSince1970:2]];
  
  [self.sut removeSession:[self sessionWithId:@"b"]];
  
  XCTAssertEqual(self.sut.metaData.count, 2U);
  XCTAssertEqual([self.sut.metaData[@"sessions"] count], 2U);
  XCTAssertNotNil(self.sut.metaData[@"sessions"][@"0"]);
  XCTAssertNotNil(self.sut.metaData[@"sessions"][@"2"]);
  XCTAssertNil(self.sut.metaData[@"sessions"][@"1"]);
  
}

#pragma mark -

- (void)testCleanUpMetaData {
  XCTAssertEqual(self.sut.metaData.count, 2U);
  XCTAssertEqual([self.sut.metaData[@"sessions"] count], 0U);
  XCTAssertEqual([self.sut.metaData[@"users"] count ], 0U);
  
  
  MSAISession *sessionA = [self sessionWithId:@"a"];
  MSAISession *sessionB = [self sessionWithId:@"b"];
  MSAISession *sessionC = [self sessionWithId:@"c"];
  
  [self.sut addSession:sessionA withDate:[NSDate dateWithTimeIntervalSince1970:3]];
  [self.sut addSession:sessionB withDate:[NSDate dateWithTimeIntervalSince1970:33]];
  [self.sut addSession:sessionC withDate:[NSDate dateWithTimeIntervalSince1970:333]];
  XCTAssertEqual([self.sut.metaData[@"sessions"] count], 3U);
  
  MSAIUser *user1 = [self.sut newUserWithId:@"1"];
  MSAIUser *user2 = [self.sut newUserWithId:@"2"];
  
  [self.sut addUser:user1 forDate:[NSDate dateWithTimeIntervalSince1970:777]];
  [self.sut addUser:user2 forDate:[NSDate dateWithTimeIntervalSince1970:7777]];
  XCTAssertEqual([self.sut.metaData[@"users"] count], 2U);
  
  [self.sut cleanUpMetaData];
  
  XCTAssertEqual(self.sut.metaData.count, 2U);
  XCTAssertEqual([self.sut.metaData[@"sessions"] count], 1U);
  XCTAssertEqual([self.sut.metaData[@"users"] count ], 1U);
  
  XCTAssertNil(self.sut.metaData[@"sessions"][@"3"]);
  XCTAssertNil(self.sut.metaData[@"sessions"][@"33"]);
  XCTAssertEqualObjects(self.sut.metaData[@"sessions"][@"333"], sessionC);
  
  XCTAssertNil(self.sut.metaData[@"users"][@"777"]);
  XCTAssertEqualObjects(self.sut.metaData[@"users"][@"7777"], user2);
}

- (void)testUnixTimestampFromDate {
  NSString *timestamp = [self.sut unixTimestampFromDate:[NSDate dateWithTimeIntervalSince1970:42]];
  XCTAssertEqualObjects(timestamp, @"42");
}

- (void)testSessionHelperNotifications {
  self.sut = OCMPartialMock([MSAIContextHelper new]);

  OCMExpect([self.sut updateDidEnterBackgroundTime]);
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UIApplicationDidEnterBackgroundNotification object:nil]];
  
  OCMExpect([self.sut startNewSessionIfNeeded]);
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UIApplicationWillEnterForegroundNotification object:nil]];
  
  OCMExpect([self.sut endSession]);
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UIApplicationWillTerminateNotification object:nil]];
  
  OCMVerifyAllWithDelay((id)self.sut, 0.1);
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
