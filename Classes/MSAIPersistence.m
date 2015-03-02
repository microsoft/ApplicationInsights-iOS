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

static dispatch_queue_t persistenceQueue;
static dispatch_once_t onceToken = nil;

static NSFileManager *fileManager;
static NSMutableArray *crashFiles;
static NSString *settingsFile;
static NSString *lastCrashFilename;
static NSString *analyzerInProgressFile;

@implementation MSAIPersistence


#pragma mark - Public

//TODO remove the completion block and implement notification-handling in MSAICrashManager
+ (void)persistBundle:(NSArray *)bundle ofType:(MSAIPersistenceType)type withCompletionBlock:(void (^)(BOOL success))completionBlock {
  [self persistBundle:bundle ofType:type withCompletionBlock:completionBlock enableNotifications:YES];
}

+ (void)persistAfterErrorWithBundle:(NSArray *)bundle {
  if(bundle && ([bundle count] > 0)) {
    id envelope = [bundle firstObject];
    if(envelope && [envelope isKindOfClass:[MSAIEnvelope class]]) {
      if([((MSAIEnvelope *) envelope).data isKindOfClass:[MSAICrashData class]]) {
        [self persistBundle:bundle ofType:MSAIPersistenceTypeHighPriority withCompletionBlock:nil enableNotifications:NO];
      }
      else {
        [self persistBundle:bundle ofType:MSAIPersistenceTypeRegular withCompletionBlock:nil enableNotifications:NO];
      }
    }
  }
}

/**
* Creates a serial background queue that saves the Bundle using NSKeyedArchiver and NSData's writeToFile:atomically
*
* In case if type MSAIPersistenceTypeFakeCrash, we don't send out a kMSAIPersistenceSuccessNotification.
*
*/
+ (void)persistBundle:(NSArray *)bundle ofType:(MSAIPersistenceType)type withCompletionBlock:(void (^)(BOOL success))completionBlock enableNotifications:(BOOL)sendNotifications {
  dispatch_once(&onceToken, ^{
    persistenceQueue = dispatch_queue_create(kPersistenceQueueString, DISPATCH_QUEUE_SERIAL);
  });

  if(bundle && bundle.count > 0) {
    NSString *fileURL = [self newFileURLForPriority:type];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bundle];

    if(data) {
      __weak typeof(self) weakSelf = self;
      dispatch_async(persistenceQueue, ^{
        typeof(self) strongSelf = weakSelf;
        BOOL success = [data writeToFile:fileURL atomically:YES];
        if(success) {
          MSAILog(@"Wrote %@", fileURL);
          if(sendNotifications && type != MSAIPersistenceTypeFakeCrash) {
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
}


/**
* Uses the persistenceQueue to retrieve the next bundle synchronously.
*
* @returns the next available bundle or nil
*/
+ (NSArray *)nextBundle {
  dispatch_once(&onceToken, ^{
    persistenceQueue = dispatch_queue_create(kPersistenceQueueString, DISPATCH_QUEUE_SERIAL);
  });

  __weak typeof(self) weakSelf = self;
  __block NSArray *bundle = nil;

  dispatch_sync(persistenceQueue, ^() {
    typeof(self) strongSelf = weakSelf;
    NSString *path = [strongSelf nextURLWithPriority:MSAIPersistenceTypeHighPriority];
    if(!path) {
      path = [strongSelf nextURLWithPriority:MSAIPersistenceTypeRegular];
    }

    if(path) {
      bundle = [strongSelf bundleAtPath:path];
    }
  });
  
  //in some cases, bundle may be non-nil but empty
  //setting it to nil to indicate that nothing's there.
  if([bundle count] == 0) {
    bundle = nil;
  }

  return bundle;
}

/**
* Method used to persist the "fake" crash reports. Fake crash reports are handled but are similar to the other bundle
* types under the hood.
*/
+ (void)persistFakeReportBundle:(NSArray *)bundle {
  [self persistBundle:bundle ofType:MSAIPersistenceTypeFakeCrash withCompletionBlock:nil];
}

/*
* @Returns a bundle that includes a fake crash report.
 */
+ (NSArray *)fakeReportBundle {
  NSString *path = [self nextURLWithPriority:MSAIPersistenceTypeFakeCrash];
  if(path && [path isKindOfClass:[NSString class]] && path.length > 0) {
    NSArray *bundle = [self bundleAtPath:path];
    if(bundle) {
      return bundle;
    }
  }
  return nil;
}

#pragma mark - Private

/**
* Deserializes a bundle from disk using NSKeyedUnarchiver and deletes it from disk
* @return a bundle of data or nil
*/
+ (NSArray *)bundleAtPath:(NSString *)path {
  if(path) {
    if([path rangeOfString:kFileBaseString].location != NSNotFound) {
      NSArray *bundle = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
      if(bundle) {
        [self deleteBundleAtPath:path];
        return bundle;
      }
    }
  }
  return nil;
}

/**
* Deletes a file at the given path.
*/
+ (void)deleteBundleAtPath:(NSString *)path {
  if([path rangeOfString:kFileBaseString].location != NSNotFound) {
    NSError *error = nil;
    [[NSFileManager new] removeItemAtPath:path error:&error];
    if(error) {
      MSAILog(@"Error deleting file at path %@", path);
    }
    else {
      MSAILog(@"Successfully deleted file at path %@", path);
    }
  }
  else {
    MSAILog(@"Empty path, so nothing can be deleted");
  }
}

/**
* Creates the path for a file depending on the MSAIPersistenceType.
* The filename includes the timestamp.
* For each MSAIPersistenceType, we create a folder within the app's Application Support directory directory
*/
+ (NSString *)newFileURLForPriority:(MSAIPersistenceType)type {
  [self createApplicationSupportDirectoryIfNeeded];

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
+ (void)createFolderAtPathIfNeeded:(NSString *)path {
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
+ (void)createApplicationSupportDirectoryIfNeeded {
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
+ (NSString *)nextURLWithPriority:(MSAIPersistenceType)type {
  [self createApplicationSupportDirectoryIfNeeded];

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

  NSArray *fileNames = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
  if(fileNames && fileNames.count > 0) {
    return [path stringByAppendingPathComponent:[fileNames firstObject]];
  }
  else {
    return nil;
  }
}

/**
** Send a kMSAIPersistenceSuccessNotification to the main thread to notify observers that we have successfully saved a file
** This is typically used to trigger sending.
**/
+ (void)sendBundleSavedNotification {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMSAIPersistenceSuccessNotification
                                                        object:nil
                                                      userInfo:nil];
  });
}





+ (void)initCrashValuesIfNeeded {
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    fileManager = [NSFileManager new];
    crashFiles = [NSMutableArray new];
    settingsFile = [ msai_settingsDir() stringByAppendingPathComponent:MSAI_CRASH_SETTINGS];
    analyzerInProgressFile = [msai_settingsDir() stringByAppendingPathComponent:MSAI_CRASH_ANALYZER];

    if([fileManager fileExistsAtPath:analyzerInProgressFile]) {
      NSError *error = nil;
      [fileManager removeItemAtPath:analyzerInProgressFile error:&error];
    }
  });
}

+ (BOOL)crashAnalyzerFilePresent {
  [self initCrashValuesIfNeeded];
  return [fileManager fileExistsAtPath:analyzerInProgressFile];
}

+ (void)writeAnalyzerFile {
  [self initCrashValuesIfNeeded];

  [fileManager createFileAtPath:analyzerInProgressFile contents:nil attributes:nil];
}

+ (void)writeCrashData:(NSData *)crashData {
  [self initCrashValuesIfNeeded];

  NSString *cacheFilename = [NSString stringWithFormat:@"%.0f", [NSDate timeIntervalSinceReferenceDate]];
  [crashData writeToFile:[msai_settingsDir() stringByAppendingPathComponent:cacheFilename] atomically:YES];
}

+ (void)deleteAnalyzerFile {
  [self initCrashValuesIfNeeded];

  NSError *error = NULL;

  if([fileManager fileExistsAtPath:analyzerInProgressFile]) {
    [fileManager removeItemAtPath:analyzerInProgressFile error:&error];
  }
}

/**
*	 Remove all crash reports for each from the file system
*
* This is currently only used as a helper method for tests
*/
+ (void)cleanCrashReportDirectory {
  [self initCrashValuesIfNeeded];

  for(NSUInteger i = 0; i < [crashFiles count]; i++) {
    [self cleanCrashReportWithFilename:crashFiles[i]];
  }
}

+ (void)cleanCrashReportWithFilename:(NSString *)filename {
  [self initCrashValuesIfNeeded];

  if(!filename) return;

  NSError *error = NULL;

  [fileManager removeItemAtPath:filename error:&error];
  [fileManager removeItemAtPath:[filename stringByAppendingString:@".data"] error:&error];
  [fileManager removeItemAtPath:[filename stringByAppendingString:@".meta"] error:&error];
  [fileManager removeItemAtPath:[filename stringByAppendingString:@".desc"] error:&error];

  [crashFiles removeObject:filename];
}

+ (NSString *)nextCrashFile {
  [self initCrashValuesIfNeeded];

  if([crashFiles count] == 0)
    return nil;

  else return crashFiles[0];
}

+ (void)loadCrashFiles {
  [self initCrashValuesIfNeeded];

  if([fileManager fileExistsAtPath:msai_settingsDir()]) {
    NSError *error = NULL;

    NSArray *dirArray = [fileManager contentsOfDirectoryAtPath:msai_settingsDir() error:&error];

    for(NSString *file in dirArray) {
      NSString *filePath = [msai_settingsDir() stringByAppendingPathComponent:file];

      NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:&error];
      if([fileAttributes[NSFileType] isEqualToString:NSFileTypeRegular] &&
          [fileAttributes[NSFileSize] intValue] > 0 &&
          ![file hasSuffix:@".DS_Store"] &&
          ![file hasSuffix:@".analyzer"] &&
          ![file hasSuffix:@".plist"] &&
          ![file hasSuffix:@".data"] &&
          ![file hasSuffix:@".meta"] &&
          ![file hasSuffix:@".desc"]) {
        [crashFiles addObject:filePath];
      }
    }
  }
}

+ (BOOL)crashesDirEmpty {
  [self initCrashValuesIfNeeded];
  
  [self loadCrashFiles];

  if([crashFiles count] > 0) {
    MSAILog(@"INFO: %lu pending crash reports found.", (unsigned long) [crashFiles count]);
    return YES;
  } else {
    return NO;
  }
}

@end
