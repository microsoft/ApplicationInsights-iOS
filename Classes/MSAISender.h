#import <Foundation/Foundation.h>


@interface MSAISender : NSObject

/**
* Utility class that's responsible for sending a bundle of data to the server
*/

/*
* Interval for sending data to the server. Default value 15 seconds.
 */
@property (nonatomic, assign) NSInteger senderInterval;

/*
* Threshold for sending data to the server. Default batch size for debugging is 150, for release
* configuration, the batch size is 5.
 */
@property (nonatomic, assign) NSInteger senderBatchSize;


- (void)triggerSending;

@end
