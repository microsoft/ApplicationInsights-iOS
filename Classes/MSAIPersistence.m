
#import "MSAIPersistence.h"

NSString *const highPrioString = @"highPrio";
NSString *const regularPrioString = @"regularPrio";
NSString *const fakeCrashString = @"fakeCrash";
NSString *const fileBaseString = @"app-insights-bundle-";

NSString *const kMSAIPersistenceSuccessNotification = @"MSAIPersistenceSuccessNotification";

static dispatch_queue_t persistenceQueue;
static dispatch_once_t onceToken = nil;


@implementation MSAIPersistence

#pragma mark - Public


+ (void)persistBundle:(NSArray *)bundle withPriority:(MSAIPersistencePriority)priority withCompletionBlock:(void (^)(BOOL success))completionBlock {
  dispatch_once(&onceToken, ^{
    persistenceQueue = dispatch_queue_create("com.microsoft.appInsights.persistenceQueue", DISPATCH_QUEUE_SERIAL);
  });

  if(bundle && bundle.count > 0) {
    NSString *fileURL;

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bundle];
    if(data) {
      __weak typeof(self) weakSelf = self;
      dispatch_async(persistenceQueue, ^{
        typeof(self) strongSelf = weakSelf;
        NSString *fileURL = [strongSelf newFileURLForPriority:priority];
        BOOL success = [data writeToFile:fileURL atomically:YES];
        if(success) {
          NSLog(@"Wrote %@", fileURL);
          [strongSelf sendBundleSavedNotification];
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

+ (NSArray *)nextBundle {
  NSString *path = [self nextURLWithPriority:MSAIPersistencePriorityHigh];
  if(!path) {
    path = [self nextURLWithPriority:MSAIPersistencePriorityRegular];
  }

  if(path) {
    NSArray *bundle = [self bundleAtPath:path];
    if(bundle) {
      return bundle;
    }
    else {
      return nil;
    }
  }
  else {
    return nil;
  }
}

+ (void)persistFakeReportBundle:(NSArray *)bundle {
  [self persistBundle:bundle withPriority:MSAIPersistencePriorityFakeCrash withCompletionBlock:nil];
}

+ (NSArray *)fakeReportBundle {
  NSString *path = [self nextURLWithPriority:MSAIPersistencePriorityFakeCrash];
  if(path && [path isKindOfClass:[NSString class]] && path.length > 0) {
    NSArray *bundle = [self bundleAtPath:path];
    if(bundle) {
      return bundle;
    }
  }
  return nil;
}

#pragma mark - Private

+ (NSArray *)bundleAtPath:(NSString *)path {
  if(path) {
    if([path rangeOfString:fileBaseString].location != NSNotFound) {
      NSArray *bundle = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
      if(bundle) {
        [self deleteBundleAtPath:path];
        return bundle;
      }
    }
  }
  return nil;
}

+ (void)deleteBundleAtPath:(NSString *)path {
  if([path rangeOfString:fileBaseString].location != NSNotFound) {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
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

+ (NSString *)newFileURLForPriority:(MSAIPersistencePriority)priority {
  NSString *documentFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  //TODO use something else than timestamp
  NSString *timestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
  NSString *fileName = [NSString stringWithFormat:@"%@%@", fileBaseString, timestamp];
  NSString *filePath;

  switch(priority) {
    case MSAIPersistencePriorityHigh: {
      [self createFolderAtPathIfNeeded:[documentFolder stringByAppendingPathComponent:highPrioString]];
      filePath = [[documentFolder stringByAppendingPathComponent:highPrioString] stringByAppendingPathComponent:fileName];
      break;
    };
    case MSAIPersistencePriorityFakeCrash: {
      [self createFolderAtPathIfNeeded:[documentFolder stringByAppendingPathComponent:fakeCrashString]];
      filePath = [[documentFolder stringByAppendingPathComponent:fakeCrashString] stringByAppendingPathComponent:fileName];
      break;
    };
    default: {
      [self createFolderAtPathIfNeeded:[documentFolder stringByAppendingPathComponent:regularPrioString]];
      filePath = [[documentFolder stringByAppendingPathComponent:regularPrioString] stringByAppendingPathComponent:fileName];
      break;
    };
  }

  return filePath;
}

+ (void)createFolderAtPathIfNeeded:(NSString *)path {
  if (path && ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    if(error) {
      NSLog(@"Error while creating folder at: %@, with error: %@", path, error);
    }
  }
}

+ (NSString *)nextURLWithPriority:(MSAIPersistencePriority)priority {
  NSString *documentFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  NSString *subfolderPath;

  switch(priority) {
    case MSAIPersistencePriorityHigh: {
      subfolderPath = [documentFolder stringByAppendingPathComponent:highPrioString];
      break;
    };
    case MSAIPersistencePriorityFakeCrash: {
      subfolderPath = [documentFolder stringByAppendingPathComponent:fakeCrashString];
      break;
    };
    default: {
      subfolderPath = regularPrioString;
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

+ (void)sendBundleSavedNotification {
  dispatch_async(dispatch_get_main_queue(),^{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMSAIPersistenceSuccessNotification
                                                        object:nil
                                                      userInfo:nil];
  });
}

@end
