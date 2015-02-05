//
// Created by Benjamin Reimold on 05.02.15.
//

#import "MSAIPersistence.h"

@implementation MSAIPersistence

static NSString *activeBundlePath = @"";

+ (void)persistBundle:(NSArray *)bundle {
  if(bundle && bundle.count > 0) {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bundle];
    __weak typeof(self) weakSelf = self;

    //TODO check if we need the queue at all!
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^{
      typeof(self) strongSelf = weakSelf;
      NSString *fileURL = [strongSelf pathToBundle];
      if([data writeToFile:fileURL atomically:YES]) {
        NSLog(@"Wrote %@", fileURL);
      }
      else {
        NSLog(@"Unable to write %@", fileURL);
      }
    });
  }
}

+ (NSArray *)nextBundle {
  return nil;
}

+ (BOOL)deleteActiveBundle {
  if(activeBundlePath.length > 0) {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:activeBundlePath error:&error];
    if(error) {
      NSLog(@"Error deleting file at path %@", activeBundlePath);
      activeBundlePath = @"";

      return NO;
    }
    else {
      NSLog(@"Successfully deleted file at path %@", activeBundlePath);
      activeBundlePath = @"";
      return YES;
    }
    //TODO check if we might get a problem here!
  }
  else {
    activeBundlePath = @"";

    return NO;
  }
}

+ (NSString *)pathToBundle {
  NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  NSString *timestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
  NSString *fileName = [NSString stringWithFormat:@"app-insights-bundle-%@", timestamp];
  NSString *filePath = [cachesFolder stringByAppendingPathComponent:fileName];

  return filePath;
}

+ (NSArray *)persistedBundlePaths {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSArray *filePaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory  error:nil];
  NSLog(@"All saved bundles %@", filePaths);

  return filePaths;
}

@end
