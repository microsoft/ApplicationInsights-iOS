#import <Foundation/Foundation.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#endif

NS_ASSUME_NONNULL_BEGIN
/**
 *  Enum for representing different network statuses.
 */
typedef NS_ENUM(NSInteger, MSAIReachabilityType){
  /**
   *  Type used if no connection is available.
   */
  MSAIReachabilityTypeNone,
  /**
   *  Type used for WiFi connnection.
   */
  MSAIReachabilityTypeWIFI,
  /**
   *  Type for Edge, 3G, LTE etc.
   */
  MSAIReachabilityTypeWWAN,
  MSAIReachabilityTypeGPRS,
  MSAIReachabilityTypeEDGE,
  MSAIReachabilityType3G,
  MSAIReachabilityTypeLTE
};

FOUNDATION_EXPORT NSString* const kMSAIReachabilityTypeChangedNotification;
FOUNDATION_EXPORT NSString* const kMSAIReachabilityUserInfoName;
FOUNDATION_EXPORT NSString* const kMSAIReachabilityUserInfoType;

/**
 *  The MSAIReachability class is responsible for keep track of the network status currently used.
 *  Some customers need to send data only via WiFi. The network status is part of the context fields
 *  of an envelop object.
 */
@interface MSAIReachability()

///-----------------------------------------------------------------------------
/// @name Initialization
///-----------------------------------------------------------------------------

/**
 *  A queue to make calls to the singleton thread safe.
 */
@property (nonatomic, strong) dispatch_queue_t singletonQueue;

/**
 *  Returns a shared MSAIReachability object
 *
 *  @return singleton instance.
 */
+ (instancetype)sharedInstance;

///-----------------------------------------------------------------------------
/// @name Register for network changes
///-----------------------------------------------------------------------------

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
/**
 *  Object to determine current radio type.
 */
@property (nonatomic, strong) CTTelephonyNetworkInfo *radioInfo;
#endif

/**
 *  A queue for dispatching reachability operations.
 */
@property (nonatomic, strong) dispatch_queue_t networkQueue;

/**
 *  Register for network status notifications.
 */
- (void)startNetworkStatusTracking;

/**
 *  Unregister for network status notifications.
 */
- (void)stopNetworkStatusTracking;

///-----------------------------------------------------------------------------
/// @name Broadcast network changes
///-----------------------------------------------------------------------------

/**
 *  Updates and broadcasts network changes.
 */
- (void)notify;

///-----------------------------------------------------------------------------
/// @name Get network status
///-----------------------------------------------------------------------------

/**
 *  Get the current network type.
 *
 *  @return the connection type currently used.
 */
- (MSAIReachabilityType)activeReachabilityType;

/**
 *  Get the current network type name.
 *
 *  @return a human readable name for the current reachability type.
 */
- (NSString *)descriptionForActiveReachabilityType;

///-----------------------------------------------------------------------------
/// @name Helper
///-----------------------------------------------------------------------------

/**
 *  Returns a MSAIReachabilityType for a given radio technology name.
 *
 *  @param technology name of the active radio technology
 *
 *  @return reachability Type, which expresses the WWAN connection
 */
- (MSAIReachabilityType)wwanTypeForRadioAccessTechnology:(NSString *)technology;

/**
 *  Returns a human readable name for a given MSAIReachabilityType.
 *
 *  @param reachabilityType the reachability type to convert.
 *
 *  @return a human readable type name
 */
- (NSString *)descriptionForReachabilityType:(MSAIReachabilityType)reachabilityType;

@end
NS_ASSUME_NONNULL_END
