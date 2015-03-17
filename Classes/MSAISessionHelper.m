#import "AppInsightsPrivate.h"
#import "MSAISessionHelper.h"

static NSString *const kMSAIFileName = @"MSAISessions";
static NSString *const kMSAIFileType = @"plist";
static char *const MSAISessionOperationsQueue = "com.microsoft.appInsights.sessionQueue";

@interface MSAISessionHelper()

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) dispatch_queue_t operationsQueue;
@property (nonatomic, strong) NSMutableDictionary *sessionEntries;
@property (nonatomic, strong) NSArray *sortDescriptors;

@end

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
  if(self = [super init]) {
    NSSortDescriptor *dateSort= [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    _sortDescriptors = [NSArray arrayWithObject:dateSort];
    _operationsQueue = dispatch_queue_create(MSAISessionOperationsQueue, DISPATCH_QUEUE_SERIAL);
    _fileManager = [NSFileManager new];
    _filePath = [self createFilePath];
    [self createPropertyListIfNeeded];
    [self loadFile];
  }
  return self;
}

#pragma mark - edit property list

- (void)addSessionId:(NSString *)sessionId WithTimestamp:(NSNumber *)timestamp {
  
  __weak typeof(self) weakSelf = self;
  dispatch_sync(self.operationsQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    [strongSelf.sessionEntries setObject:sessionId forKey:timestamp];
  });
}

- (NSString *)sessionIdForTimestamp:(NSNumber *)timestamp {
  __block NSString *sessionId = nil;
  
  __weak typeof(self) weakSelf = self;
  dispatch_sync(self.operationsQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    NSNumber *sessionKey = [strongSelf keyForTimestamp:timestamp];
    sessionId = [strongSelf.sessionEntries valueForKey:[sessionKey stringValue]];
  });
  
  return sessionId;
}

- (void)removeSessionId:(NSString *)sessionId {
  
  __weak typeof(self) weakSelf = self;
  dispatch_sync(self.operationsQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    // Find key for given sessionId
    // TODO: Maybe sorting dictionary keys in advance is faster
    NSString *sessionKey = nil;
    for(NSString *key in _sessionEntries) {
      if([strongSelf.sessionEntries[key] isEqualToString:sessionId]) {
        sessionKey = key;
        break;
      }
    }
    
    // Remove entry
    if(sessionKey){
      [strongSelf.sessionEntries removeObjectForKey:sessionKey];
    }
  });
}

- (void)cleanUpSessionIds {
  
  __weak typeof(self) weakSelf = self;
  dispatch_sync(self.operationsQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    // Get most recent session
    NSArray *sortedKeys = [strongSelf sortedKeys];
    NSInteger lastIndex = [sortedKeys indexOfObject:[sortedKeys lastObject]];
    NSString *lastKey = sortedKeys[lastIndex];
    
    // Clear list and add most recent session
    NSString *lastValue = strongSelf.sessionEntries[lastKey];
    [strongSelf.sessionEntries removeAllObjects];
    [strongSelf.sessionEntries setObject:lastValue forKey:lastKey];
  });
}

#pragma mark - Helper

- (NSNumber *)keyForTimestamp:(NSNumber *)timestamp {
  
  for(NSNumber *key in [self sortedKeys]){
    if([self iskey:key forTimestamp:timestamp]){
      return timestamp;
    }
  }
  return nil;
}

- (NSArray *)sortedKeys {
  NSMutableArray *keys = [[_sessionEntries allKeys] mutableCopy];
  [keys sortUsingDescriptors:_sortDescriptors];
  
  return keys;
}

- (BOOL)iskey:(NSNumber *)key forTimestamp:(NSNumber *)timestamp {
  return timestamp > key;
}

- (void)saveFile {
  [_sessionEntries writeToFile:_filePath atomically:YES];
}

- (void)loadFile {
  _sessionEntries = [[NSMutableDictionary alloc] initWithContentsOfFile: _filePath];
}

- (NSString *)createFilePath{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *fileName = [NSString stringWithFormat:@"%@.%@", kMSAIFileName, kMSAIFileType];
  return [documentsDirectory stringByAppendingPathComponent:fileName];
}

- (void)createPropertyListIfNeeded {
  if (_fileManager && _filePath && ![_fileManager fileExistsAtPath: _filePath]) {
    NSError *error;
    NSString *bundle = [[NSBundle mainBundle] pathForResource:kMSAIFileName ofType:kMSAIFileType]; //5
    [_fileManager copyItemAtPath:bundle toPath: _filePath error:&error];
    if(error){
      MSAILog(@"Could not create file %@.%@: %@", kMSAIFileName, kMSAIFileType, [error localizedDescription]);
    }
  }
}

@end
