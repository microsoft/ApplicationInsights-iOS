#import <Foundation/Foundation.h>

/**
 * Utility class that's responsible for sending a bundle of data to the server
 */

@interface MSAISender : NSObject

/*
* Interval for sending data to the server in seconds.
*
* Default: 15
*/
@property (nonatomic, assign) NSInteger senderInterval;

/*
* Threshold for sending data to the server. Default batch size for debugging is 150, for release
* configuration, the batch size is 5.
*
* @warning: we advice to not set the batch size below 5 events.
*
* Default: 5
*/
@property (nonatomic, assign) NSInteger senderBatchSize;


/*
* Triggers sending the saved data. Does nothing if nothing has been persisted, yet.
*
* @return
*/
- (void)sendSavedData;

@end
