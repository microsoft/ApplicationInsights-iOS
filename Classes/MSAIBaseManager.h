#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 The internal superclass for all component managers
 
 */

@interface MSAIBaseManager : NSObject

///-----------------------------------------------------------------------------
/// @name Modules
///-----------------------------------------------------------------------------


/**
 Defines the server URL to send data to or request data from
 
 By default this is set to the AppInsights servers and there rarely should be a
 need to modify that.
 */
@property (nonatomic, copy) NSString *serverURL;


@end
