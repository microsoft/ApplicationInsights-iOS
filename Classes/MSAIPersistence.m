//
// Created by Benjamin Reimold on 05.02.15.
//

#import "MSAIPersistence.h"

NSString *const highPrioString = @"highPrio";
NSString *const regularPrioString = @"regularPrio";
NSString *const fakeCrashString = @"fakeCrash";
NSString *const fileBaseString = @"app-insights-bundle-";

@implementation MSAIPersistence

#pragma mark - Public

+ (void)persistBundle:(NSArray *)bundle withPriority:(MSAIPersistencePriority)priority withCompletionBlock:(void (^)(BOOL success))completionBlock {
  if(bundle && bundle.count > 0) {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bundle];
    if(data) {
      __weak typeof(self) weakSelf = self;

      dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
      dispatch_async(backgroundQueue, ^{
        typeof(self) strongSelf = weakSelf;
        NSString *fileURL = [strongSelf createFullPathForBundleWithPriority:priority];
        if(completionBlock) {
          completionBlock([data writeToFile:fileURL atomically:YES]);
        }
      });
    }
    else if(completionBlock != nil) {
      completionBlock(NO);
    }
  }
}

+ (void)persistBundle:(NSArray *)bundle withPriority:(MSAIPersistencePriority)priority {
  if(bundle && bundle.count > 0) {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bundle];
    if(data) {
      __weak typeof(self) weakSelf = self;

      dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
      dispatch_async(backgroundQueue, ^{
        typeof(self) strongSelf = weakSelf;
        NSString *fileURL = [strongSelf createFullPathForBundleWithPriority:priority];
        if([data writeToFile:fileURL atomically:YES]) {
          NSLog(@"Wrote %@", fileURL);
        }
        else {
          NSLog(@"Unable to write %@", fileURL);
        }
      });

    }
    else {
      NSLog(@"Unable to create NSData from bundle.");
    }
  }
}

+ (NSArray *)nextBundle {
  NSString *path = [self nextPathToBundleForPriority:MSAIPersistencePriorityHigh];
  if(!path) {
    path = [self nextPathToBundleForPriority:MSAIPersistencePriorityRegular];
  }

  if(path) {
    NSArray *bundle = [self unarchiveBundleAtPath:path];
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
  [self persistBundle:bundle withPriority:MSAIPersistencePriorityFakeCrash];
}

+ (NSArray *)fakeReportBundle {
  NSString *path = [self nextPathToBundleForPriority:MSAIPersistencePriorityFakeCrash];
  if(path && [path isKindOfClass:[NSString class]] && path.length > 0) {
    NSArray *bundle = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if(bundle) {
      [self deleteBundleAtPath:path];
      return bundle;
    }
  }
  return nil;
}

#pragma mark - Private

+ (NSArray *)unarchiveBundleAtPath:(NSString *)path {
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

+ (NSString *)createFullPathForBundleWithPriority:(MSAIPersistencePriority)priority {
  NSString *documentFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  NSString *timestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
  NSString *fileName = [NSString stringWithFormat:@"%@%@", fileBaseString, timestamp];
  NSString *filePath;


  switch(priority) {
    case MSAIPersistencePriorityHigh: {
      [self createFoldersIfNecessaryAtPath:[documentFolder stringByAppendingPathComponent:highPrioString]];
      filePath = [[documentFolder stringByAppendingPathComponent:highPrioString] stringByAppendingPathComponent:fileName];
      break;
    };
    case MSAIPersistencePriorityFakeCrash: {
      [self createFoldersIfNecessaryAtPath:[documentFolder stringByAppendingPathComponent:fakeCrashString]];
      filePath = [[documentFolder stringByAppendingPathComponent:fakeCrashString] stringByAppendingPathComponent:fileName];
      break;
    };
    default: {
      [self createFoldersIfNecessaryAtPath:[documentFolder stringByAppendingPathComponent:regularPrioString]];
      filePath = [[documentFolder stringByAppendingPathComponent:regularPrioString] stringByAppendingPathComponent:fileName];
      break;
    };
  }


  return filePath;
}

+ (void)createFoldersIfNecessaryAtPath:(NSString *)path {
  if (path && ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    if(error) {
      NSLog(@"Error while creating folder at: %@, with error: %@", path, error);
    }
  }
}

+ (NSString *)nextPathToBundleForPriority:(MSAIPersistencePriority)priority {
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

  NSArray *fileNames = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentFolder error:nil];
  if(fileNames && fileNames.count > 0) {
    return [subfolderPath stringByAppendingPathComponent:[fileNames firstObject]];
  }
  else {
    return nil;
  }
}


@end
