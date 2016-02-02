#import "ApplicationInsightsPrivate.h"
#import "MSAIContextHelper.h"
#import "MSAIContextHelperPrivate.h"
#import "MSAIPersistencePrivate.h"
#import "MSAIUser.h"
#import "MSAISession.h"
#import "MSAISessionStateData.h"

#import "MSAITelemetryManagerPrivate.h"

#import "MSAIHelper.h"

NSString *const kMSAISessionFileName = @"MSAISessions";
NSString *const kMSAISessionFileType = @"plist";
char *const MSAISessionOperationsQueue = "com.microsoft.ApplicationInsights.sessionQueue";

NSUInteger const defaultSessionExpirationTime = 20;
NSString *const kMSAIApplicationDidEnterBackgroundTime = @"MSAIApplicationDidEnterBackgroundTime";
NSString *const kMSAIApplicationWasLaunched = @"MSAIApplicationWasLaunched";

NSString *const MSAIUserChangedNotification = @"MSAIUserChangedNotification";
NSString *const kMSAIUserInfo = @"MSAIUserInfo";

NSString *const MSAISessionStartedNotification = @"MSAISessionStartedNotification";
NSString *const MSAISessionEndedNotification = @"MSAISessionEndedNotification";
NSString *const kMSAISessionInfo = @"MSAISessionInfo";

@implementation MSAIContextHelper {
  id _appWillEnterForegroundObserver;
  id _appDidEnterBackgroundObserver;
  id _appWillTerminateObserver;
}

#pragma mark - Initialize

+ (instancetype)sharedInstance {
  static MSAIContextHelper *sharedInstance = nil;

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [self new];
  });

  return sharedInstance;
}

- (instancetype)init {
  if(self = [super init]) {
    _operationsQueue = dispatch_queue_create(MSAISessionOperationsQueue, DISPATCH_QUEUE_SERIAL);

    _autoSessionManagementDisabled = NO;
    _appBackgroundTimeBeforeSessionExpires = defaultSessionExpirationTime;

    [self registerObservers];
  }
  return self;
}

#pragma mark - Users
#pragma mark Create New Users

- (MSAIUser *)newUser {
  return ({
    MSAIUser *user = [MSAIUser new];
    user.userId = msai_appAnonID();
    user;
  });
}

#pragma mark Manual User ID Management

- (void)setUserWithConfigurationBlock:(void (^)(MSAIUser *user))userConfigurationBlock {
  MSAIUser *currentUser = [self newUser];

  userConfigurationBlock(currentUser);

  if(!currentUser) {
    return;
  }

  [self setCurrentUser:currentUser];
}

- (void)setCurrentUser:(nonnull MSAIUser *)user {
  [self sendUserChangedNotificationWithUserInfo:@{kMSAIUserInfo : user}];
}


#pragma mark - Sessions
#pragma mark Session Creation

- (MSAISession *)newSession {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
  return [self newSessionWithId:nil];
#pragma clang diagnostic pop
}

- (MSAISession *)newSessionWithId:(NSString *)sessionId {
  MSAISession *session = [MSAISession new];
  session.sessionId = sessionId ?: msai_UUID();
  //normally, this should also be saved to UserDefaults like isFirst.
  //The problem is that there are cases when committing the changes is too slow and we get
  //the wrong value. As isNew is only "true" when we start a new session, it is set in
  //directly before enqueueing the session event.
  session.isNew = @"false";

  if(![[NSUserDefaults standardUserDefaults] boolForKey:kMSAIApplicationWasLaunched]) {
    session.isFirst = @"true";
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMSAIApplicationWasLaunched];
    [[NSUserDefaults standardUserDefaults] synchronize];
  } else {
    session.isFirst = @"false";
  }
  return session;
}

#pragma mark Automatic Session Management

- (void)registerObservers {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

  __weak typeof(self) weakSelf = self;

  if(nil == _appDidEnterBackgroundObserver) {
    _appDidEnterBackgroundObserver = [nc addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                     object:nil
                                                      queue:NSOperationQueue.mainQueue
                                                 usingBlock:^(NSNotification *note) {
                                                   typeof(self) strongSelf = weakSelf;
                                                   [strongSelf updateDidEnterBackgroundTime];
                                                 }];
  }
  if(nil == _appWillEnterForegroundObserver) {
    _appWillEnterForegroundObserver = [nc addObserverForName:UIApplicationWillEnterForegroundNotification
                                                      object:nil
                                                       queue:NSOperationQueue.mainQueue
                                                  usingBlock:^(NSNotification *note) {
                                                    typeof(self) strongSelf = weakSelf;
                                                    [strongSelf startNewSessionIfNeeded];
                                                  }];
  }
  if(nil == _appWillTerminateObserver) {
    _appWillTerminateObserver = [nc addObserverForName:UIApplicationWillTerminateNotification
                                                object:nil
                                                 queue:NSOperationQueue.mainQueue
                                            usingBlock:^(NSNotification *note) {
                                              typeof(self) strongSelf = weakSelf;
                                              [strongSelf endSession];
                                            }];
  }
}

- (void)unregisterObservers {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  _appDidEnterBackgroundObserver = nil;
  _appWillEnterForegroundObserver = nil;
  _appWillTerminateObserver = nil;
}

- (void)updateDidEnterBackgroundTime {
  if(self.autoSessionManagementDisabled) {
    return;
  }
  [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:kMSAIApplicationDidEnterBackgroundTime];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)startNewSessionIfNeeded {
  if(self.autoSessionManagementDisabled) {
    return;
  }

  if(self.appBackgroundTimeBeforeSessionExpires == 0) {
    [self startNewSession];
    return;
  }

  double appDidEnterBackgroundTime = [[NSUserDefaults standardUserDefaults] doubleForKey:kMSAIApplicationDidEnterBackgroundTime];
  double timeSinceLastBackground = [[NSDate date] timeIntervalSince1970] - appDidEnterBackgroundTime;
  if(timeSinceLastBackground > self.appBackgroundTimeBeforeSessionExpires) {
    [self startNewSession];
  }
}

#pragma mark Manual Session Management

- (void)renewSessionWithId:(NSString *)sessionId {
  MSAISession *session = [self newSessionWithId:sessionId];
  NSDictionary *userInfo = @{kMSAISessionInfo : session};
  [self sendSessionStartedNotificationWithUserInfo:userInfo];
}

#pragma mark Session Lifecycle

- (void)startNewSession {
  NSString *newSessionId = msai_UUID();
  [self renewSessionWithId:newSessionId];
}

- (void)endSession {
  [self sendSessionEndedNotification];
}

#pragma mark - Notifications

- (void)sendUserChangedNotificationWithUserInfo:(NSDictionary *)userInfo {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:MSAIUserChangedNotification
                                                        object:self
                                                      userInfo:userInfo];
  });
}

- (void)sendSessionStartedNotificationWithUserInfo:(NSDictionary *)userInfo {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:MSAISessionStartedNotification
                                                        object:self
                                                      userInfo:userInfo];
  });
}

- (void)sendSessionEndedNotification {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:MSAISessionEndedNotification
                                                        object:self
                                                      userInfo:nil];
  });
}

#pragma mark - Helper

- (NSString *)unixTimestampFromDate:(NSDate *)date {
  return [NSString stringWithFormat:@"%ld", (time_t) [date timeIntervalSince1970]];
}

- (NSString *)keyForTimestamp:(NSString *)timestamp inDictionary:(NSDictionary *)dict {
  for(NSString *key in [self sortedKeysOfDictionay:dict]) {
    if([timestamp doubleValue] >= [key doubleValue]) {
      return key;
    }
  }
  return nil;
}

- (NSArray *)sortedKeysOfDictionay:(NSDictionary *)dict {
  NSMutableArray *keys = [[dict allKeys] mutableCopy];
  NSArray *sortedArray = [keys sortedArrayUsingComparator:^(id a, id b) {
    return [b compare:a options:NSNumericSearch];
  }];
  return sortedArray;
}

@end
