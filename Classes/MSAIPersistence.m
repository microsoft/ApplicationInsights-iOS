//
// Created by Benjamin Reimold on 05.02.15.
//

#import "MSAIPersistence.h"

@implementation MSAIPersistence

#pragma mark - Public

+ (void)persistBundle:(NSArray *)bundle withPriority:(MSAIPersistencePriority)priority withCompletionBlock: (void (^)(BOOL success)) completionBlock {
  //TODO implement completion block and async queue stuff
  if(bundle && bundle.count > 0) {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bundle];
    if(data) {
      __weak typeof(self) weakSelf = self;

      dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
      dispatch_async(backgroundQueue, ^{
        typeof(self) strongSelf = weakSelf;
        NSString *fileURL = [strongSelf createFullPathForBundle];
        completionBlock([data writeToFile:fileURL atomically:YES]);
      });
    }
    else if(completionBlock != nil) {
      completionBlock(NO);
    }
  }
}

+ (void)persistBundle:(NSArray *)bundle withPriority:(MSAIPersistencePriority)priority {
  //TODO implement completion block and async queue stuff

}

+ (void)persistFakeReportBundle:(NSArray *)bundle{
  // TODO save envelop for fake crash report. we need it for certain crashes
}

+ (NSArray *)fakeReportBundle{
  // TODO get most recent fake envelope (meta info needed for certain crashes)
}

+ (NSArray *)nextBundle {
  NSArray *paths = [self allBundlePaths];
  if(([paths count] > 0)) {
    for (NSString *path in paths) {
      if([path containsString:@"app-insights-bundle-"]) {
        NSArray *bundle = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if(bundle) {
          [self deleteBundleAtPath:path];
          return bundle;
        }
      }
    }
  }
  return nil;
}

#pragma mark - Private

+ (void)deleteBundleAtPath:(NSString *)path {
  if((path > 0) && ([path containsString:@"app-insights-bundle-"])) {
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

+ (NSString *)createFullPathForBundle {
  NSString *documentFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  NSString *timestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
  NSString *fileName = [NSString stringWithFormat:@"app-insights-bundle-%@", timestamp];
  NSString *filePath = [documentFolder stringByAppendingPathComponent:fileName];

  return filePath;
}

+ (NSArray *)allBundlePaths {
  NSString *documentFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  NSArray *fileNames = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentFolder  error:nil];
  NSMutableArray *fullPaths = [NSMutableArray arrayWithCapacity:fileNames.count];
  for (NSString *fileName in fileNames) {
    [fullPaths addObject:[documentFolder stringByAppendingPathComponent:fileName]];
  }
  
  return fullPaths;
}

@end
