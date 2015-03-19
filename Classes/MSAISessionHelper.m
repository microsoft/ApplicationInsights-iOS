#import "AppInsightsPrivate.h"
#import "MSAISessionHelper.h"
#import "MSAISessionHelperPrivate.h"
#import "MSAIPersistence.h"

#import "MSAIHelper.h"

static NSString *const kMSAISessionFileName = @"MSAISessions";
static NSString *const kMSAISessionFileType = @"plist";

static char *const MSAISessionOperationsQueue = "com.microsoft.appInsights.sessionQueue";

@implementation MSAISessionHelper

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
  }
  return self;
}

#pragma mark - edit property list

+ (void)addSessionId:(NSString *)sessionId withDate:(NSDate *)date {
  [[self sharedInstance] addSessionId:sessionId withDate:date];
}

- (void)addSessionId:(NSString *)sessionId withDate:(NSDate *)date {
  NSString *timestamp = [self unixTimestampFromDate:date];
  
  __weak typeof(self) weakSelf = self;
  dispatch_sync(self.operationsQueue, ^{
    typeof(self) strongSelf = weakSelf;

    [strongSelf.sessionEntries setObject:sessionId forKey:timestamp];
    [[MSAIPersistence sharedInstance] persistSessionIds:strongSelf.sessionEntries];
  });
}

+ (NSString *)sessionIdForDate:(NSDate *)date {
  return [[self sharedInstance] sessionIdForDate:date];
}

- (NSString *)sessionIdForDate:(NSDate *)date {
  NSString *timestamp = [self unixTimestampFromDate:date];

  __block NSString *sessionId = nil;
  
  __weak typeof(self) weakSelf = self;
  dispatch_sync(self.operationsQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    NSString *sessionKey = [strongSelf keyForTimestamp:timestamp];
    sessionId = [strongSelf.sessionEntries valueForKey:sessionKey];
  });
  
  return sessionId;
}

+ (void)removeSessionId:(NSString *)sessionId {
  [[self sharedInstance] removeSessionId:sessionId];
}

- (void)removeSessionId:(NSString *)sessionId {
  __weak typeof(self) weakSelf = self;

  dispatch_sync(self.operationsQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    [_sessionEntries enumerateKeysAndObjectsUsingBlock:^(NSString *blockTimestamp, NSString *blockSessionId, BOOL *stop) {
      if ([blockSessionId isEqualToString:sessionId]) {
        [_sessionEntries removeObjectForKey:blockTimestamp];
        *stop = YES;
      }
    }];
    [[MSAIPersistence sharedInstance] persistSessionIds:strongSelf.sessionEntries];
  });
}

+ (void)cleanUpSessionIds {
  [[self sharedInstance] cleanUpSessionIds];
}

- (void)cleanUpSessionIds {
  __weak typeof(self) weakSelf = self;
  
  dispatch_sync(self.operationsQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    NSInteger sessionsCount = strongSelf.sessionEntries.count;
    if (sessionsCount >= 0) {

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
