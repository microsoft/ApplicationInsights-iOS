#import "MSAIChannel.h"
#import "MSAISender.h"
#import "MSAIClientConfig.h"
#import "MSAIEnvelope.h"
#import "MSAIData.h"

@implementation MSAIChannel{
  MSAIClientConfig *_clientConfig;
  MSAISender *_sender;
}

- (instancetype)initWithClientConfig:(MSAIClientConfig *)clientConfig{
  
  if ((self = [self init])) {
    _clientConfig = clientConfig;
    _sender = [MSAISender sharedSender];
  }
  return self;
}

- (void)sendDataItem:(MSAITelemetryData *)dataItem{

  //TODO: enqueue dataItem
}

@end
