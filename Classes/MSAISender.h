#import <Foundation/Foundation.h>


@interface MSAISender : NSObject

@property (nonatomic, assign) NSInteger senderInterval;
@property (nonatomic, assign) NSInteger senderThreshold;

- (void)triggerSending;

@end
