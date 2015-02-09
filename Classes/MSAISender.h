#import <Foundation/Foundation.h>

/**
 * Utility class that's responsible for sending a bundle of data to the server
 */

@interface MSAISender : NSObject

/*
* Triggers sending the saved data. Does nothing if nothing has been persisted, yet.
*
* @return
*/
- (void)sendSavedData;

@end
