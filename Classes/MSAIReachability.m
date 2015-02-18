#import "MSAIReachability.h"
#import "MSAIReachabilityPrivate.h"
#import <CoreFoundation/CoreFoundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import <netinet/in.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>

NSString * const kMSAIReachabilityTypeChangedNotification = @"MSAIReachabilityTypeChangedNotification";
static char *const MSAIReachabilitySingletonQueue = "com.microsoft.appInsights.singletonQueue";
static char *const MSAIReacabilityNetworkQueue = "com.microsoft.appInsights.networkQueue";

static void MSAIReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info){
  if(info != NULL && [(__bridge NSObject*) info isKindOfClass: [MSAIReachability class]]){
    [(__bridge MSAIReachability *)info notify];
  }
}

@implementation MSAIReachability{
  SCNetworkReachabilityRef _reachability;
  MSAIReachabilityType _reachabilityType;
  BOOL _running;
}

#pragma mark - Initialize & configure shared instance

+ (instancetype)sharedInstance {
  static MSAIReachability *sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [MSAIReachability new];
    sharedInstance.singletonQueue = dispatch_queue_create(MSAIReachabilitySingletonQueue, DISPATCH_QUEUE_SERIAL);
    sharedInstance.networkQueue = dispatch_queue_create(MSAIReacabilityNetworkQueue, DISPATCH_QUEUE_SERIAL);
    
    if ([CTTelephonyNetworkInfo class]) {
      sharedInstance.radioInfo = [CTTelephonyNetworkInfo new];
    }
    [sharedInstance configureReachability];
  });
  return sharedInstance;
}

- (void)registerRadioObserver{
  __weak typeof(self) weakSelf = self;
  [NSNotificationCenter.defaultCenter addObserverForName:CTRadioAccessTechnologyDidChangeNotification
                                                  object:nil
                                                   queue:nil
                                              usingBlock:^(NSNotification *note)
   {
     typeof(self) strongSelf = weakSelf;
     [strongSelf notify];
   }];
}

- (void)unregisterRadioObserver{
  [NSNotificationCenter.defaultCenter removeObserver:self name:CTRadioAccessTechnologyDidChangeNotification object:nil];
}

- (void)configureReachability{
  __weak typeof(self) weakSelf = self;
  dispatch_sync(self.singletonQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef networkReachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
    if (networkReachability != NULL){
      strongSelf->_reachability = networkReachability;
    }
  });
}

- (void)dealloc{
  [self stopNetworkStatusTracking];
  if (_reachability != NULL){
    CFRelease(_reachability);
  }
  self.singletonQueue = nil;
  self.networkQueue = nil;
}

#pragma mark - Register for network changes

- (void)startNetworkStatusTracking{
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.singletonQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    context.info = (__bridge void *)self;
    if(SCNetworkReachabilitySetCallback(strongSelf->_reachability, MSAIReachabilityCallback, &context)){
      if(SCNetworkReachabilitySetDispatchQueue(strongSelf->_reachability, strongSelf.networkQueue)){
        if ([CTTelephonyNetworkInfo class]) {
          [strongSelf registerRadioObserver];
        }
        strongSelf->_running = YES;
      }else{
        SCNetworkReachabilitySetCallback(strongSelf->_reachability, NULL, NULL);
      }
    }
  });
}

- (void)stopNetworkStatusTracking{
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.singletonQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    if ([CTTelephonyNetworkInfo class]) {
      [strongSelf unregisterRadioObserver];
    }
    
    if (strongSelf->_reachability != NULL){
      SCNetworkReachabilitySetCallback(strongSelf->_reachability, NULL, NULL);
      SCNetworkReachabilitySetDispatchQueue(strongSelf->_reachability, NULL);
    }
  });
}

#pragma mark - Broadcast network changes

- (void)notify{
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.singletonQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    _reachabilityType = [strongSelf activeReachabilityType];
    NSDictionary *notificationDict = @{@"name":[strongSelf descriptionForReachabilityType:strongSelf->_reachabilityType],
                                       @"type":@(strongSelf->_reachabilityType)};
    dispatch_async(dispatch_get_main_queue(), ^{
      [[NSNotificationCenter defaultCenter] postNotificationName:kMSAIReachabilityTypeChangedNotification object:nil userInfo:notificationDict];
    });
  });
}

#pragma mark - Get network status

- (MSAIReachabilityType)activeReachabilityType{
  
  MSAIReachabilityType reachabilityType = MSAIReachabilityTypeNone;
  SCNetworkReachabilityFlags flags;
  
  if(SCNetworkReachabilityGetFlags(_reachability, &flags)){
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0){
      return MSAIReachabilityTypeNone;
    }
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0){
      reachabilityType = MSAIReachabilityTypeWIFI;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)){
      if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0){
        reachabilityType = MSAIReachabilityTypeWIFI;
      }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN){
      reachabilityType = MSAIReachabilityTypeWWAN;
      if ([CTTelephonyNetworkInfo class] && self.radioInfo) {
        reachabilityType = [self wwanTypeForRadioAccessTechnology:self.radioInfo.currentRadioAccessTechnology];
      }
    }
  }
  
  return reachabilityType;
}

- (NSString *)descriptionForActiveReachabilityType{
  MSAIReachabilityType currentType = [self activeReachabilityType];
  
  return [self descriptionForReachabilityType:currentType];
}

#pragma mark - Helper

- (MSAIReachabilityType)wwanTypeForRadioAccessTechnology:(NSString *)technology{
  MSAIReachabilityType radioType = MSAIReachabilityTypeNone;
  
  // TODO: Check mapping
  if([technology isEqualToString:CTRadioAccessTechnologyGPRS]||
     [technology isEqualToString:CTRadioAccessTechnologyCDMA1x]){
    radioType = MSAIReachabilityTypeGPRS;
  }else if([technology isEqualToString:CTRadioAccessTechnologyEdge]){
    radioType = MSAIReachabilityTypeEDGE;
  }else if([technology isEqualToString:CTRadioAccessTechnologyWCDMA]||
           [technology isEqualToString:CTRadioAccessTechnologyHSDPA]||
           [technology isEqualToString:CTRadioAccessTechnologyHSUPA]||
           [technology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]||
           [technology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]||
           [technology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]||
           [technology isEqualToString:CTRadioAccessTechnologyeHRPD]){
    radioType = MSAIReachabilityType3G;
  }else if([technology isEqualToString:CTRadioAccessTechnologyLTE]){
    radioType = MSAIReachabilityTypeLTE;
  }
  return radioType;
}

- (NSString *)descriptionForReachabilityType:(MSAIReachabilityType)reachabilityType{
  switch(reachabilityType){
    case MSAIReachabilityTypeWIFI:
      return @"WIFI";
    case MSAIReachabilityTypeWWAN:
      return @"WWAN";
    case MSAIReachabilityTypeGPRS:
      return @"GPRS";
    case MSAIReachabilityTypeEDGE:
      return @"EDGE";
    case MSAIReachabilityType3G:
      return @"3G";
    case MSAIReachabilityTypeLTE:
      return @"LTE";
    default:
      return @"None";
  }
}

@end
