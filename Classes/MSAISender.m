#import "MSAISender.h"
#import "MSAISenderConfig.h"

@implementation MSAISender{
  MSAISenderConfig *_senderConfig;
}

+ (id)sharedSender;
{
  static dispatch_once_t onceToken;
  static id sharedSender = nil;
  
  dispatch_once( &onceToken, ^{
    sharedSender = [[[self class] alloc] init];
  });
  
  return sharedSender;
}

- (instancetype)init{
  
  if ((self = [self init])) {
    _senderConfig = [MSAISenderConfig new];
    _senderQueue = [[NSOperationQueue alloc] init];
  }
  return self;
}

- (void)enqueueDataItem:(MSAIEnvelope *)dataItem{
  
  //TODO: create operation object and add it to the queue
}

@end
