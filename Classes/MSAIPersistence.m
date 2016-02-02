#import "MSAIPersistence.h"
#import "MSAIPersistencePrivate.h"
#import "MSAIEnvelope.h"
#import "ApplicationInsightsPrivate.h"
#import "MSAIHelper.h"

NSString *const kHighPrioString = @"highPrio";
NSString *const kRegularPrioString = @"regularPrio";
NSString *const kFileBaseString = @"app-insights-bundle-";

NSString *const MSAIPersistenceSuccessNotification = @"MSAIPersistenceSuccessNotification";
char const *kPersistenceQueueString = "com.microsoft.ApplicationInsights.persistenceQueue";
NSUInteger const defaultFileCount = 50;

@implementation MSAIPersistence{
  BOOL _maxFileCountReached;
}


#pragma mark - Public

+ (instancetype)sharedInstance {
  static MSAIPersistence *sharedInstance;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [MSAIPersistence new];
    [sharedInstance createApplicationSupportDirectoryIfNeeded];
  });
  return sharedInstance;
}

- (instancetype)init {
  self = [super init];
  if ( self ) {
    _persistenceQueue = dispatch_queue_create(kPersistenceQueueString, DISPATCH_QUEUE_SERIAL);
    _requestedBundlePaths = [NSMutableArray new];
    _maxFileCount = defaultFileCount;
    
    // Evantually there are old files on disk, the flag will be updated before the first event gets created
    _maxFileCountReached = YES;
  }
  return self;
}

- (void)persistBundle:(NSData *)bundle ofType:(MSAIPersistenceType)type withCompletionBlock:(nullable void (^)(BOOL success))completionBlock {
  [self persistBundle:bundle ofType:type enableNotifications:YES withCompletionBlock:completionBlock];
}

/**
 * Creates a serial background queue that saves the Bundle using NSKeyedArchiver and NSData's writeToFile:atomically
 *
 */
- (void)persistBundle:(NSData *)bundle ofType:(MSAIPersistenceType)type enableNotifications:(BOOL)sendNotifications withCompletionBlock:(void (^)(BOOL success))completionBlock {
  
    NSString *fileURL = [self newFileURLForPersitenceType:type];
    
    if(bundle) {
      __weak typeof(self) weakSelf = self;
      dispatch_async(self.persistenceQueue, ^{
        typeof(self) strongSelf = weakSelf;
        BOOL success = [bundle writeToFile:fileURL atomically:YES];
        if(success) {
          MSAILog(@"Wrote %@", fileURL);
          if(sendNotifications) {
            [strongSelf sendBundleSavedNotification];
          }
        }
        
        if(completionBlock) {
          completionBlock(success);
        }
      });
    }
    else if(completionBlock != nil) {
      MSAILog(@"Unable to write %@", fileURL);
      completionBlock(NO);
    }
    else {
      MSAILog(@"Unable to write %@", fileURL);
      //TODO send out a fail notification?
    }
}

- (BOOL)isFreeSpaceAvailable{
  return !_maxFileCountReached;
}

- (NSString *)requestNextPath {
  __block NSString *path = nil;
  __weak typeof(self) weakSelf = self;
  dispatch_sync(self.persistenceQueue, ^() {
    typeof(self) strongSelf = weakSelf;
    
    path = [strongSelf nextURLWithPriority:MSAIPersistenceTypeHighPriority];
    if(!path) {
      path = [strongSelf nextURLWithPriority:MSAIPersistenceTypeRegular];
    }
    
    if(path){
      [self.requestedBundlePaths addObject:path];
    }
  });
  return path;
}

/**
 * Deserializes a bundle from disk using NSKeyedUnarchiver and deletes it from disk
 * @return a bundle of data or nil
 */
- (NSArray *)bundleAtPath:(NSString *)path {
  NSArray *bundle = nil;
  if(path && [path rangeOfString:kFileBaseString].location != NSNotFound) {
    bundle = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
  }
  return bundle;
}

- (NSData *)dataAtPath:(NSString *)path {
  NSData *data = nil;
  
  if(path && [path rangeOfString:kFileBaseString].location != NSNotFound) {
    data = [NSData dataWithContentsOfFile:path];
  }
  return data;
}

/**
 * Deletes a file at the given path.
 */
- (void)deleteFileAtPath:(NSString *)path {
  __weak typeof(self) weakSelf = self;
  dispatch_sync(self.persistenceQueue, ^() {
    typeof(self) strongSelf = weakSelf;
    if([path rangeOfString:kFileBaseString].location != NSNotFound) {
      NSError *error = nil;
      if(![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
        MSAILog(@"Error deleting file at path %@", path);
      }
      else {
        MSAILog(@"Successfully deleted file at path %@", path);
        [strongSelf.requestedBundlePaths removeObject:path];
      }
    }else {
      MSAILog(@"Empty path, so nothing can be deleted");
    }
  });
  
}

- (void)giveBackRequestedPath:(NSString *) path {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.persistenceQueue, ^() {
    typeof(self) strongSelf = weakSelf;
    
    [strongSelf.requestedBundlePaths removeObject:path];
  });
}

#pragma mark - Private

- (NSString *)newFileURLForPersitenceType:(MSAIPersistenceType)type {
  static NSString *fileDir;
  static dispatch_once_t dirToken;
  
  dispatch_once(&dirToken, ^{
    NSString *applicationSupportDir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    fileDir = [applicationSupportDir stringByAppendingPathComponent:@"com.microsoft.ApplicationInsights/"];
    [self createFolderAtPathIfNeeded:fileDir];
  });
  
  NSString *uuid = msai_UUID();
  NSString *fileName = [NSString stringWithFormat:@"%@%@", kFileBaseString, uuid];
  NSString *filePath;
  
  switch(type) {
    case MSAIPersistenceTypeHighPriority: {
      [self createFolderAtPathIfNeeded:[fileDir stringByAppendingPathComponent:kHighPrioString]];
      filePath = [[fileDir stringByAppendingPathComponent:kHighPrioString] stringByAppendingPathComponent:fileName];
      break;
    };
    default: {
      [self createFolderAtPathIfNeeded:[fileDir stringByAppendingPathComponent:kRegularPrioString]];
      filePath = [[fileDir stringByAppendingPathComponent:kRegularPrioString] stringByAppendingPathComponent:fileName];
      break;
    };
  }
  
  return filePath;
}

/**
 * create a folder within at the given path
 */
- (void)createFolderAtPathIfNeeded:(NSString *)path {
  if(path && ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
    NSError *error = nil;
    if(![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error]) {
      MSAILog(@"Error while creating folder at: %@, with error: %@", path, error);
    }
  }
}

/**
 * Create ApplicationSupport directory if necessary and exclude it from iCloud Backup
 */
- (void)createApplicationSupportDirectoryIfNeeded {
  NSString *appplicationSupportDir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
  if(![[NSFileManager defaultManager] fileExistsAtPath:appplicationSupportDir isDirectory:NULL]) {
    NSError *error = nil;
    if(![[NSFileManager defaultManager] createDirectoryAtPath:appplicationSupportDir withIntermediateDirectories:YES attributes:nil error:&error]) {
      MSAILog(@"%@", error.localizedDescription);
    }
    else {
      NSURL *url = [NSURL fileURLWithPath:appplicationSupportDir];
      if(![url setResourceValue:@YES
                         forKey:NSURLIsExcludedFromBackupKey
                          error:&error]) {
        MSAILog(@"Error excluding %@ from backup %@", url.lastPathComponent, error.localizedDescription);
      }
      else {
        MSAILog(@"Exclude %@ from backup", url);
      }
    }
  }
}

/**
 * @returns the URL to the next file depending on the specified type. If there's no file, return nil.
 */
- (NSString *)nextURLWithPriority:(MSAIPersistenceType)type {
  
  NSString *directoryPath = [self folderPathForPersistenceType:type];
  NSError *error = nil;
  NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:directoryPath]
                                                     includingPropertiesForKeys:@[NSURLNameKey]
                                                                        options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                          error:&error];
  
  // each track method asks, if space is still available. Getting the file count for each event would be too expensive,
  // so let's get it here
  if(type == MSAIPersistenceTypeRegular){
    _maxFileCountReached = fileNames.count >= _maxFileCount;
  }
  
  if(fileNames && fileNames.count > 0) {
    for(NSURL *filename in fileNames){
      NSString *absolutePath = filename.path;
      if(![self.requestedBundlePaths containsObject:absolutePath]){
        return absolutePath;
      }
    }
  }
  return nil;
}

- (NSString *)folderPathForPersistenceType:(MSAIPersistenceType)type {
  static NSString *persistenceFolder;
  static dispatch_once_t persistenceFolderToken;
  dispatch_once(&persistenceFolderToken, ^{
    NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    persistenceFolder = [documentsFolder stringByAppendingPathComponent:@"com.microsoft.ApplicationInsights/"];
    [self createFolderAtPathIfNeeded:persistenceFolder];
  });
  
  NSString *subfolderPath;
  
  switch(type) {
    case MSAIPersistenceTypeHighPriority: {
      subfolderPath = kHighPrioString;
      break;
    };
    case MSAIPersistenceTypeRegular: {
      subfolderPath = kRegularPrioString;
      break;
    }
  }
  NSString *path = [persistenceFolder stringByAppendingPathComponent:subfolderPath];
  
  return path;
}

/**
 * Send a MSAIPersistenceSuccessNotification to the main thread to notify observers that we have successfully saved a file
 * This is typocally used to trigger sending.
 */
- (void)sendBundleSavedNotification{
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:MSAIPersistenceSuccessNotification
                                                        object:nil
                                                      userInfo:nil];
  });
}

@end
