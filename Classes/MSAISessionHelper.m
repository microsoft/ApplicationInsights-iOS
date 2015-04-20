#import "ApplicationInsightsPrivate.h"
#import "MSAISessionHelper.h"
#import "MSAISessionHelperPrivate.h"
#import "MSAIPersistencePrivate.h"
#import "MSAISessionStateData.h"

#import "MSAITelemetryManagerPrivate.h"

#import "MSAIHelper.h"

static NSString *const kMSAISessionFileName = @"MSAISessions";
static NSString *const kMSAISessionFileType = @"plist";
static char *const MSAISessionOperationsQueue = "com.microsoft.ApplicationInsights.sessionQueue";

static NSInteger const defaultSessionExpirationTime = 20;
static NSString *const kMSAIApplicationDidEnterBackgroundTime = @"MSAIApplicationDidEnterBackgroundTime";
NSString *const kMSAIApplicationWasLaunched = @"MSAIApplicationWasLaunched";

NSString *const MSAISessionStartedNotification = @"MSAISessionStartedNotification";
NSString *const MSAISessionEndedNotification = @"MSAISessionEndedNotification";
NSString *const kMSAISessionInfoSession = @"MSAISessionInfoSession";

@implementation MSAISessionHelper{
  id _appWillEnterForegroundObserver;
  id _appDidEnterBackgroundObserver;
  id _appWillTerminateObserver;
}

#pragma mark - Initialize

+ (id)sharedInstance {
  static MSAISessionHelper *sharedInstance = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [self new];
  });
  
  return sharedInstance;
}

- (instancetype)init {
  if (self = [super init]) {
    _operationsQueue = dispatch_queue_create(MSAISessionOperationsQueue, DISPATCH_QUEUE_SERIAL);
    NSMutableDictionary *restoredSessionIds = [[[MSAIPersistence sharedInstance] sessionIds] mutableCopy];
    _sessionEntries = restoredSessionIds ? restoredSessionIds : [NSMutableDictionary new];
    [self registerObservers];
  }
  return self;
}

#pragma mark - edit property list
- (void)addSession:(MSAISession *)session withDate:(NSDate *)date {

  NSString *timestamp = [self unixTimestampFromDate:date];
  
  __weak typeof(self) weakSelf = self;
  dispatch_sync(self.operationsQueue, ^{
    typeof(self) strongSelf = weakSelf;

    [strongSelf.sessionEntries setObject:session forKey:timestamp];
    [[MSAIPersistence sharedInstance] persistSessionIds:strongSelf.sessionEntries];
  });
}

+ (MSAISession *)sessionForDate:(NSDate *)date {
  return [[self sharedInstance] sessionForDate:date];
}

- (MSAISession *)sessionForDate:(NSDate *)date {
  NSString *timestamp = [self unixTimestampFromDate:date];

  __block MSAISession *session = nil;
  
  __weak typeof(self) weakSelf = self;
  dispatch_sync(self.operationsQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    NSString *sessionKey = [strongSelf keyForTimestamp:timestamp];
    session = [strongSelf.sessionEntries valueForKey:sessionKey];
  });
  
  return session;
}

+ (void)removeSession:(MSAISession *)session {
  [[self sharedInstance] removeSession:session];
}

- (void)removeSession:(MSAISession *)session {
  __weak typeof(self) weakSelf = self;

  dispatch_sync(self.operationsQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    [_sessionEntries enumerateKeysAndObjectsUsingBlock:^(NSString *blockTimestamp, MSAISession *blockSession, BOOL *stop) {
      if ([blockSession.sessionId isEqualToString:session.sessionId]) {
        [_sessionEntries removeObjectForKey:blockTimestamp];
        *stop = YES;
      }
    }];
    [[MSAIPersistence sharedInstance] persistSessionIds:strongSelf.sessionEntries];
  });
}

+ (void)cleanUpSessions {
  [[self sharedInstance] cleanUpSessions];
}

- (void)cleanUpSessions {
  __weak typeof(self) weakSelf = self;
  
  dispatch_sync(self.operationsQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    NSInteger sessionsCount = strongSelf.sessionEntries.count;
    if (sessionsCount > 0) {

      // Get most recent session
      NSArray *sortedKeys = [strongSelf sortedKeys];
      NSString *recentSessionKey = sortedKeys.firstObject;
      
      // Clear list and add most recent session
      NSString *lastValue = strongSelf.sessionEntries[recentSessionKey];
      [strongSelf.sessionEntries removeAllObjects];
      [strongSelf.sessionEntries setObject:lastValue forKey:recentSessionKey];
      [[MSAIPersistence sharedInstance] persistSessionIds:strongSelf.sessionEntries];
    }
  });
}

#pragma mark - Session update

- (void)registerObservers {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  __weak typeof(self) weakSelf = self;

  if (nil == _appDidEnterBackgroundObserver) {
    _appDidEnterBackgroundObserver = [nc addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                     object:nil
                                                      queue:NSOperationQueue.mainQueue
                                                 usingBlock:^(NSNotification *note) {
                                                   typeof(self) strongSelf = weakSelf;
                                                   [strongSelf updateDidEnterBackgroundTime];
                                                 }];
  }
  if (nil == _appWillEnterForegroundObserver) {
    _appWillEnterForegroundObserver = [nc addObserverForName:UIApplicationWillEnterForegroundNotification
                                                      object:nil
                                                       queue:NSOperationQueue.mainQueue
                                                  usingBlock:^(NSNotification *note) {
                                                    typeof(self) strongSelf = weakSelf;
                                                    [strongSelf startNewSessionIfNeeded];
                                                  }];
  }
  if (nil == _appWillTerminateObserver) {
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
  [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:kMSAIApplicationDidEnterBackgroundTime];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (MSAISession *)startNewSessionIfNeeded {
  return [[MSAISessionHelper sharedInstance] startNewSessionIfNeeded];
}

- (MSAISession *)startNewSessionIfNeeded {
  double appDidEnterBackgroundTime = [[NSUserDefaults standardUserDefaults] doubleForKey:kMSAIApplicationDidEnterBackgroundTime];
  double timeSinceLastBackground = [[NSDate date] timeIntervalSince1970] - appDidEnterBackgroundTime;
  if (timeSinceLastBackground > defaultSessionExpirationTime) {

    return [self startNewSession];
  }
  return nil;
}

+ (MSAISession *)startNewSession {
  return [[self sharedInstance] startNewSession];
}

- (MSAISession *)startNewSession {
  MSAISession *session = [MSAISession new];
  session.sessionId = msai_UUID();
  session.isNew = @"false";
  
  if (![[NSUserDefaults standardUserDefaults] boolForKey:kMSAIApplicationWasLaunched]) {
    session.isFirst = @"true";
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMSAIApplicationWasLaunched];
    [[NSUserDefaults standardUserDefaults] synchronize];
  } else {
    session.isFirst = @"false";
  }
  
  [self addSession:session withDate:[NSDate date]];
  
  NSDictionary *userInfo = @{kMSAISessionInfoSession:session};
  [self sendSessionStartedNotificationWithUserInfo:userInfo];
  
  return session;
}

- (void)endSession {
  [self sendSessionEndedNotification];
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
    return [NSString stringWithFormat:@"%ld", (time_t)[date timeIntervalSince1970]];
}

- (NSString *)keyForTimestamp:(NSString *)timestamp {
  for (NSString *key in [self sortedKeys]){
    if([timestamp doubleValue] > [key doubleValue]){
      return key;
    }
  }
  return nil;
}

- (NSArray *)sortedKeys {
  NSMutableArray *keys = [[_sessionEntries allKeys] mutableCopy];
  NSArray *sortedArray = [keys sortedArrayUsingComparator:^(id a, id b) {
    return [b compare:a options:NSNumericSearch];
  }];
  return sortedArray;
}

@end
