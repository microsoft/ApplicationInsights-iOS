#import "MSAIPersistence.h"

NSString *const kHighPrioString = @"highPrio";
NSString *const kRegularPrioString = @"regularPrio";
NSString *const kFakeCrashString = @"fakeCrash";
NSString *const kFileBaseString = @"app-insights-bundle-";

NSString *const kMSAIPersistenceSuccessNotification = @"MSAIPersistenceSuccessNotification";
char const *kPersistenceQueueString = "com.microsoft.appInsights.persistenceQueue";

static dispatch_queue_t persistenceQueue;
static dispatch_once_t onceToken = nil;


@implementation MSAIPersistence

#pragma mark - Public

/**
* Creates a serial background queue that saves the Bundle using NSKeyedArchiver and NSData's writeToFile:atomically
* In case MSAIPersistenceTypeFakeCrash, we don't send out a kMSAIPersistenceSuccessNotification, for other types, we do.
* The optional bundle is optional.
*/
+ (void)persistBundle:(NSArray *)bundle ofType:(MSAIPersistenceType)type withCompletionBlock:(void (^)(BOOL success))completionBlock {
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
          NSLog(@"Wrote %@", fileURL);
          if(type != MSAIPersistenceTypeFakeCrash) {
            [strongSelf sendBundleSavedNotification];
          }
        }
        if(completionBlock) {
          completionBlock(success);
        }
      });
    }
    else if(completionBlock != nil) {
      NSLog(@"Unable to write %@", fileURL);
      completionBlock(NO);
    }
    else {
      NSLog(@"Unable to write %@", fileURL);
    }
  }
}

/**
* Uses the persistenceQueue to retrieve the next bundle synchronously.
* @returns the next available bundle or nil
*/
+ (NSArray *)nextBundle {
  dispatch_once(&onceToken, ^{
    persistenceQueue = dispatch_queue_create(kPersistenceQueueString, DISPATCH_QUEUE_SERIAL);
  });
  
  __weak typeof(self) weakSelf = self;
  __block NSArray *bundle = nil;

  dispatch_sync(persistenceQueue, ^(){
    typeof(self) strongSelf = weakSelf;
    NSString *path = [strongSelf nextURLWithPriority:MSAIPersistenceTypeHighPriority];
    if(!path) {
      path = [strongSelf nextURLWithPriority:MSAIPersistenceTypeRegular];
    }

    if(path) {
      bundle = [strongSelf bundleAtPath:path];
    }
  });

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
      NSLog(@"Error deleting file at path %@", path);
    }
    else {
      NSLog(@"Successfully deleted file at path %@", path);
    }
  }
  else {
    NSLog(@"Empty path, so nothing can be deleted");
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
  //TODO use something else than timestamp
  NSString *timestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
  NSString *fileName = [NSString stringWithFormat:@"%@%@", kFileBaseString, timestamp];
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
      NSLog(@"Error while creating folder at: %@, with error: %@", path, error);
    }
  }
}

/**
* Create ApplicationSupport directory if necessary and exclude it from iCloud Backup
*/
+ (void)createApplicationSupportDirectoryIfNeeded {
  NSString *appplicationSupportDir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
  if (![[NSFileManager defaultManager] fileExistsAtPath:appplicationSupportDir isDirectory:NULL]) {
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:appplicationSupportDir withIntermediateDirectories:YES attributes:nil error:&error]) {
      NSLog(@"%@", error.localizedDescription);
    }
    else {
      NSURL *url = [NSURL fileURLWithPath:appplicationSupportDir];
      if (![url setResourceValue:@YES
                          forKey:NSURLIsExcludedFromBackupKey
                           error:&error])
      {
        NSLog(@"Error excluding %@ from backup %@", url.lastPathComponent, error.localizedDescription);
      }
      else {
        NSLog(@"Exclude %@ from backup", url);
      }
    }
  }
}

/**
* @returns the URL to the next file depeneding for the specified type. If there's no file, return nil.
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
* Send a kMSAIPersistenceSuccessNotification to the main thread to notify observers that we have successfully saved a file
* This is typocally used to trigger sending.
*/
+ (void)sendBundleSavedNotification {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMSAIPersistenceSuccessNotification
                                                        object:nil
                                                      userInfo:nil];
  });
}

@end
