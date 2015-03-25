#import "MSAIHelper.h"
#import "MSAIKeychainUtils.h"
#import "AppInsights.h"
#import "AppInsightsPrivate.h"
#import <QuartzCore/QuartzCore.h>

#import <sys/sysctl.h>

static NSString *const kMSAIUtcDateFormatter = @"utcDateFormatter";

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000
@interface NSData (MSAIiOS7)
- (NSString *)base64Encoding;
@end
#endif

typedef struct {
  uint8_t       info_version;
  const char    msai_version[16];
  const char    msai_build[16];
} msai_info_t;

msai_info_t applicationinsights_library_info __attribute__((section("__TEXT,__msai_ios,regular,no_dead_strip"))) = {
  .info_version = 1,
  .msai_version = MSAI_C_VERSION,
  .msai_build = MSAI_C_BUILD
};

#pragma mark NSString helpers

NSString *msai_URLEncodedString(NSString *inputString) {
  return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                   (__bridge CFStringRef)inputString,
                                                                   NULL,
                                                                   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                   kCFStringEncodingUTF8)
                           );
}

NSString *msai_URLDecodedString(NSString *inputString) {
  return CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                   (__bridge CFStringRef)inputString,
                                                                                   CFSTR(""),
                                                                                   kCFStringEncodingUTF8)
                           );
}

// Return ISO 8601 string representation of the date
NSString *msai_utcDateString(NSDate *date){
  static NSDateFormatter *dateFormatter;
  
  // NSDateFormatter is not thread-safe prior to iOS 7
  if (msai_isPreiOS7Environment()) {
    NSMutableDictionary *threadDictionary = [NSThread currentThread].threadDictionary;
    NSDateFormatter *dateFormatter = threadDictionary[kMSAIUtcDateFormatter];
    
    if (!dateFormatter) {
      dateFormatter = [NSDateFormatter new];
      NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
      dateFormatter.locale = enUSPOSIXLocale;
      dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
      dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
      threadDictionary[kMSAIUtcDateFormatter] = dateFormatter;
    }
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
  }
  
  static dispatch_once_t dateFormatterToken;
  dispatch_once(&dateFormatterToken, ^{
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = enUSPOSIXLocale;
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
  });
  
  NSString *dateString = [dateFormatter stringFromDate:date];
  
  return dateString;
}

NSString *msai_base64String(NSData * data, unsigned long length) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
  SEL base64EncodingSelector = NSSelectorFromString(@"base64EncodedStringWithOptions:");
  if ([data respondsToSelector:base64EncodingSelector]) {
    return [data base64EncodedStringWithOptions:0];
  } else {
#endif
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [data base64Encoding];
#pragma clang diagnostic pop
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
  }
#endif
}

NSString *msai_settingsDir(void) {
  static NSString *settingsDir = nil;
  static dispatch_once_t predSettingsDir;
  
  dispatch_once(&predSettingsDir, ^{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    // temporary directory for crashes grabbed from PLCrashReporter
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    settingsDir = [paths[0] stringByAppendingPathComponent:kMSAIIdentifier];
    
    if (![fileManager fileExistsAtPath:settingsDir]) {
      NSDictionary *attributes = @{NSFilePosixPermissions : @0755};
      NSError *theError = NULL;
      
      [fileManager createDirectoryAtPath:settingsDir withIntermediateDirectories: YES attributes: attributes error: &theError];
    }
  });
  
  return settingsDir;
}


NSString *msai_keychainMSAIServiceName(void) {
  static NSString *serviceName = nil;
  static dispatch_once_t predServiceName;
  
  dispatch_once(&predServiceName, ^{
    serviceName = [NSString stringWithFormat:@"%@.MSAI", msai_mainBundleIdentifier()];
  });
  
  return serviceName;
}

NSString *msai_mainBundleIdentifier(void) {
  return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

NSString *msai_encodeInstrumentationKey(NSString *inputString) {
  return (inputString ? msai_URLEncodedString(inputString) : msai_URLEncodedString(msai_mainBundleIdentifier()));
}

NSString *msai_osVersionBuild(void) {
  void *result = NULL;
  size_t result_len = 0;
  int ret;
  
  /* If our buffer is too small after allocation, loop until it succeeds -- the requested destination size
   * may change after each iteration. */
  do {
    /* Fetch the expected length */
    if ((ret = sysctlbyname("kern.osversion", NULL, &result_len, NULL, 0)) == -1) {
      break;
    }
    
    /* Allocate the destination buffer */
    if (result != NULL) {
      free(result);
    }
    result = malloc(result_len);
    
    /* Fetch the value */
    ret = sysctlbyname("kern.osversion", result, &result_len, NULL, 0);
  } while (ret == -1 && errno == ENOMEM);
  
  /* Handle failure */
  if (ret == -1) {
    int saved_errno = errno;
    
    if (result != NULL) {
      free(result);
    }
    
    errno = saved_errno;
    return NULL;
  }
  
  NSString *osBuild = [NSString stringWithCString:result encoding:NSUTF8StringEncoding];
  free(result);
  
  NSString *osVersion = [[UIDevice currentDevice] systemVersion];
  
  return [NSString stringWithFormat:@"%@(%@)", osVersion, osBuild];
}

NSString *msai_osName(void){
  return [[UIDevice currentDevice] systemName];
}

NSString *msai_appVersion(void){
  NSString *build = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
  NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
  
  if(version){
    return [NSString stringWithFormat:@"%@ (%@)", version, build];
  }else{
    return build;
  }
}

NSString *msai_deviceType(void){
  
  UIUserInterfaceIdiom idiom = [UIDevice currentDevice].userInterfaceIdiom;
  
  switch (idiom) {
    case UIUserInterfaceIdiomPad:
      return @"Tablet";
    case UIUserInterfaceIdiomPhone:
      return @"Phone";
    default:
      return @"Unknown";
  }
}

NSString *msai_screenSize(void){
  CGSize screenSize = [UIScreen mainScreen].bounds.size;
  return [NSString stringWithFormat:@"%dx%d",(int)screenSize.height, (int)screenSize.width];
}

NSString *msai_sdkVersion(void){
  return [NSString stringWithFormat:@"ios:%@", [NSString stringWithUTF8String:applicationinsights_library_info.msai_version]];
}

NSString *msai_sdkBuild(void) {
  return [NSString stringWithUTF8String:applicationinsights_library_info.msai_build];
}

NSString *msai_devicePlatform(void) {
  
  size_t size;
  sysctlbyname("hw.machine", NULL, &size, NULL, 0);
  char *answer = (char*)malloc(size);
  if (answer == NULL)
    return @"";
  sysctlbyname("hw.machine", answer, &size, NULL, 0);
  NSString *platform = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
  free(answer);
  return platform;
}

NSString *msai_deviceLanguage(void) {
  return [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];;
}

NSString *msai_deviceLocale(void) {
  NSLocale *locale = [NSLocale currentLocale];
  return [locale objectForKey:NSLocaleIdentifier];
}

NSString *msai_UUIDPreiOS6(void) {
  // Create a new UUID
  CFUUIDRef uuidObj = CFUUIDCreate(nil);
  
  // Get the string representation of the UUID
  NSString *resultUUID = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
  CFRelease(uuidObj);
  
  return resultUUID;
}

NSString *msai_UUID(void) {
  NSString *resultUUID = nil;
  
  id uuidClass = NSClassFromString(@"NSUUID");
  if (uuidClass) {
    resultUUID = [[NSUUID UUID] UUIDString];
  } else {
    resultUUID = msai_UUIDPreiOS6();
  }
  
  return resultUUID;
}

NSString *msai_appAnonID(void) {
  static NSString *appAnonID = nil;
  static dispatch_once_t predAppAnonID;
  
  dispatch_once(&predAppAnonID, ^{
    // first check if we already have an install string in the keychain
    NSString *appAnonIDKey = @"appAnonID";
    
    __block NSError *error = nil;
    appAnonID = [MSAIKeychainUtils getPasswordForUsername:appAnonIDKey andServiceName:msai_keychainMSAIServiceName() error:&error];
    
    if (!appAnonID) {
      appAnonID = msai_UUID();
      // store this UUID in the keychain (on this device only) so we can be sure to always have the same ID upon app startups
      if (appAnonID) {
        // add to keychain in a background thread, since we got reports that storing to the keychain may take several seconds sometimes and cause the app to be killed
        // and we don't care about the result anyway
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
          [MSAIKeychainUtils storeUsername:appAnonIDKey
                               andPassword:appAnonID
                            forServiceName:msai_keychainMSAIServiceName()
                            updateExisting:YES
                             accessibility:kSecAttrAccessibleWhenUnlockedThisDeviceOnly
                                     error:&error];
        });
      }
    }
  });
  
  return appAnonID;
}

BOOL msai_isPreiOS7Environment(void) {
  static BOOL isPreiOS7Environment = YES;
  static dispatch_once_t checkOS;
  
  dispatch_once(&checkOS, ^{
    // NSFoundationVersionNumber_iOS_6_1 = 993.00
    // We hardcode this, so compiling with iOS 6 is possible while still being able to detect the correct environment
    
    // runtime check according to
    // https://developer.apple.com/library/prerelease/ios/documentation/UserExperience/Conceptual/TransitionGuide/SupportingEarlieriOS.html
    if (floor(NSFoundationVersionNumber) <= 993.00) {
      isPreiOS7Environment = YES;
    } else {
      isPreiOS7Environment = NO;
    }
  });
  
  return isPreiOS7Environment;
}

BOOL msai_isPreiOS8Environment(void) {
  static BOOL isPreiOS8Environment = YES;
  static dispatch_once_t checkOS8;
  
  dispatch_once(&checkOS8, ^{
    // NSFoundationVersionNumber_iOS_7_1 = 1047.25
    // We hardcode this, so compiling with iOS 7 is possible while still being able to detect the correct environment
    
    // runtime check according to
    // https://developer.apple.com/library/prerelease/ios/documentation/UserExperience/Conceptual/TransitionGuide/SupportingEarlieriOS.html
    if (floor(NSFoundationVersionNumber) <= 1047.25) {
      isPreiOS8Environment = YES;
    } else {
      isPreiOS8Environment = NO;
    }
  });
  
  return isPreiOS8Environment;
}

BOOL msai_isRunningInAppExtension(void) {
  static BOOL isRunningInAppExtension = NO;
  static dispatch_once_t checkAppExtension;
  
  dispatch_once(&checkAppExtension, ^{
    isRunningInAppExtension = ([[[NSBundle mainBundle] executablePath] rangeOfString:@".appex/"].location != NSNotFound);
  });
  
  return isRunningInAppExtension;
}

BOOL msai_isAppStoreEnvironment(void){
  
  #if !TARGET_IPHONE_SIMULATOR
  // check if we are really in an app store environment
  if (![[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"]) {
    return YES;
  }
  #endif
  
  return NO;
}
