#import <Foundation/Foundation.h>

@class MSAIAppClient;
@class MSAIEnvelope;

@interface MSAISender : NSObject

@property (nonatomic, strong) NSOperationQueue *senderQueue;

+ (id)sharedSender;

- (void)enqueueDataItem:(MSAIEnvelope *)dataItem;

@end
