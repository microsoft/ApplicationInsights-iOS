#import "MSAIPersistence.h"
#import "MSAIEnvelope.h"
#import "MSAICrashData.h"
#import "AppInsightsPrivate.h"
#import "MSAIHelper.h"

NSString *const kHighPrioString = @"highPrio";
NSString *const kRegularPrioString = @"regularPrio";
NSString *const kFakeCrashString = @"fakeCrash";
NSString *const kFileBaseString = @"app-insights-bundle-";

NSString *const kMSAIPersistenceSuccessNotification = @"MSAIPersistenceSuccessNotification";
char const *kPersistenceQueueString = "com.microsoft.appInsights.persistenceQueue";
NSUInteger const defaultFileCount = 15;

@implementation MSAIPersistence

#pragma mark - Public

+ (instancetype)sharedInstance{
  static MSAIPersistence *sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [MSAIPersistence new];
    [sharedInstance createApplicationSupportDirectoryIfNeeded];
  });
  return sharedInstance;
}

- (instancetype)init{
  self = [super init];
  if ( self ) {
    _persistenceQueue = dispatch_queue_create(kPersistenceQueueString, DISPATCH_QUEUE_SERIAL);
    _requestedBundlePaths = [NSMutableArray new];
    _maxFileCount = defaultFileCount;
  }
  return self;
}

//TODO remove the completion block and implement notification-handling in MSAICrashManager
- (void)persistBundle:(NSArray *)bundle ofType:(MSAIPersistenceType)type withCompletionBlock:(void (^)(BOOL success))completionBlock {
  [self persistBundle:bundle ofType:type withCompletionBlock:completionBlock enableNotifications:YES];
}

/**
 * Creates a serial background queue that saves the Bundle using NSKeyedArchiver and NSData's writeToFile:atomically
 *
 * In case if type MSAIPersistenceTypeFakeCrash, we don't send out a kMSAIPersistenceSuccessNotification.
 *
 */
- (void)persistBundle:(NSArray *)bundle ofType:(MSAIPersistenceType)type withCompletionBlock:(void (^)(BOOL success))completionBlock enableNotifications:(BOOL)sendNotifications {
  
  if(bundle && bundle.count > 0) {
    NSString *fileURL = [self newFileURLForPriority:type];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bundle];
    
    if(data) {
      __weak typeof(self) weakSelf = self;
      dispatch_async(self.persistenceQueue, ^{
        typeof(self) strongSelf = weakSelf;
        BOOL success = [data writeToFile:fileURL atomically:YES];
        if(success) {
          MSAILog(@"Wrote %@", fileURL);
          if(sendNotifications && type != MSAIPersistenceTypeFakeCrash) {
            [strongSelf sendBundleSavedNotificationWithPath];
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
}

- (BOOL)isFreeSpaceAvailable{
  __block NSUInteger fileCount = 0;
  dispatch_sync(self.persistenceQueue, ^() {
    NSError *error = nil;
    NSString *path = [self folderPathWithPriority:MSAIPersistenceTypeRegular];
    NSArray *fileNames = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:&error];
    fileCount = fileNames.count;
  });
  BOOL freeSpaceAvailable = fileCount < _maxFileCount;
  
  return freeSpaceAvailable;
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
 * Method used to persist the "fake" crash reports. Fake crash reports are handled but are similar to the other bundle
 * types under the hood.
 */
- (void)persistFakeReportBundle:(NSArray *)bundle {
  [self persistBundle:bundle ofType:MSAIPersistenceTypeFakeCrash withCompletionBlock:nil];
}

/*
 * @Returns a bundle that includes a fake crash report.
 */
- (NSArray *)fakeReportBundle {
  NSString *path = [self nextURLWithPriority:MSAIPersistenceTypeFakeCrash];
  if(path && [path isKindOfClass:[NSString class]] && path.length > 0) {
    NSArray *bundle = [self bundleAtPath:path];
    if(bundle) {
      return bundle;
    }
  }
  return nil;
}

/**
 * Deserializes a bundle from disk using NSKeyedUnarchiver and deletes it from disk
 * @return a bundle of data or nil
 */
- (NSArray *)bundleAtPath:(NSString *)path {
  __block NSArray *bundle = nil;

  dispatch_sync(self.persistenceQueue, ^() {
    
    if(path && [path rangeOfString:kFileBaseString].location != NSNotFound) {
      bundle = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
  });
  return bundle;
}

/**
 * Deletes a file at the given path.
 */
- (void)deleteBundleAtPath:(NSString *)path {
  __weak typeof(self) weakSelf = self;
  dispatch_sync(self.persistenceQueue, ^() {
    typeof(self) strongSelf = weakSelf;
    if([path rangeOfString:kFileBaseString].location != NSNotFound) {
      NSError *error = nil;
      [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
      if(error) {
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
  dispatch_sync(self.persistenceQueue, ^() {
    typeof(self) strongSelf = weakSelf;
    
    [strongSelf.requestedBundlePaths removeObject:path];
  });
}

#pragma mark - Private

/**
 * Creates the path for a file depending on the MSAIPersistenceType.
 * The filename includes the timestamp.
 * For each MSAIPersistenceType, we create a folder within the app's Application Support directory directory
 */
- (NSString *)newFileURLForPriority:(MSAIPersistenceType)type {
  
  NSString *applicationSupportDir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
  NSString *uuid = msai_UUID();
  NSString *fileName = [NSString stringWithFormat:@"%@%@", kFileBaseString, uuid];
  NSString *filePath;
  
  switch(type) {
    case MSAIPersistenceTypeHighPriority: {
      [self createFolderAtPathIfNeeded:[applicationSupportDir stringByAppendingPathComponent:kHighPrioString]];
      filePath = [[applicationSupportDir stringByAppendingPathComponent:kHighPrioString] stringByAppendingPathComponent:fileName];
      break;
    };
    case MSAIPersistenceTypeFakeCrash: {
      [self createFolderAtPathIfNeeded:[applicationSupportDir stringByAppendingPathComponent:kFakeCrashString]];
      filePath = [[applicationSupportDir stringByAppendingPathComponent:kFakeCrashString] stringByAppendingPathComponent:fileName];
      break;
    };
    default: {
      [self createFolderAtPathIfNeeded:[applicationSupportDir stringByAppendingPathComponent:kRegularPrioString]];
      filePath = [[applicationSupportDir stringByAppendingPathComponent:kRegularPrioString] stringByAppendingPathComponent:fileName];
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
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    if(error) {
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
  
  NSString *path = [self folderPathWithPriority:type];
  NSArray *fileNames = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
  if(fileNames && fileNames.count > 0) {
    for(NSString *filename in fileNames){
      NSString *absolutePath = [path stringByAppendingPathComponent:filename];
      if(![self.requestedBundlePaths containsObject:absolutePath]){
        return absolutePath;
      }
    }
  }
  
  return nil;
}

- (NSString *)folderPathWithPriority:(MSAIPersistenceType)type {
  NSString *documentFolder = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
  NSString *subfolderPath;
  
  switch(type) {
    case MSAIPersistenceTypeHighPriority: {
      subfolderPath = kHighPrioString;
      break;
    };
    case MSAIPersistenceTypeFakeCrash: {
      subfolderPath = kFakeCrashString;
      break;
    };
    default: {
      subfolderPath = kRegularPrioString;
      break;
    }
  }
  
  NSString *path = [documentFolder stringByAppendingPathComponent:subfolderPath];
  
  return path;
}

/**
 ** Send a kMSAIPersistenceSuccessNotification to the main thread to notify observers that we have successfully saved a file
 ** This is typocally used to trigger sending.
 **/
- (void)sendBundleSavedNotificationWithPath{
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMSAIPersistenceSuccessNotification
                                                        object:nil
                                                      userInfo:nil];
  });
}

@end
