#import <Foundation/Foundation.h>
#import "MSAIReachability.h"

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
  MSAIReachabilityTypeWifi,
  /**
   *  Type for Edge, 3G, LTE etc.
   */
  MSAIReachabilityTypeWwan
};

extern NSString *kMSAIReachabilityTypeChangedNotification;

/**
 *  The MSAIReachability class is responsible for keep track of the network status currently used.
 *  Some customers need to send data only via WiFi. The network status is part of the context fields
 *  of an envelop object.
 */
@interface MSAIReachability()

///-----------------------------------------------------------------------------
/// @name Initialization & Configuration
///-----------------------------------------------------------------------------

/**
 *  The host, which is used to determien the current network status. 
 */
@property (nonatomic, strong) NSString *hostName;

/**
 *  Returns a shared MSAIReachability object
 *
 *  @return singleton instance.
 */
+ (instancetype)sharedInstance;

/**
 *  Configure singleton instance.
 *
 *  @param hostName the host name, which should be used to determine the network connection.
 */
- (void)configureWithHost:(NSString *)hostName;

///-----------------------------------------------------------------------------
/// @name Register for network changes
///-----------------------------------------------------------------------------

/**
 *  Register for network status notifications.
 */
- (void)startNetworkStatusTracking;

/**
 *  Unregister for network status notifications.
 */
- (void)stopNetworkStatusTracking;

///-----------------------------------------------------------------------------
/// @name Get network status
///-----------------------------------------------------------------------------

/**
 *  Get the current network type.
 *
 *  @return the connection type currently used.
 */
- (MSAIReachabilityType)activeReachabilityType;

@end
