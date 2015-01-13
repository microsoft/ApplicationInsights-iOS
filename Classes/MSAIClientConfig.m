#import "MSAIClientConfig.h"

@implementation MSAIClientConfig

- (instancetype)initWithInstrumentationKey:(NSString *)instrumentationKey{
  if ((self = [self init])) {
    self.instrumentationKey = instrumentationKey;
  }
  return self;
}

@end
