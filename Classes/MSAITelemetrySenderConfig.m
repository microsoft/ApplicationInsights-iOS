#import "MSAITelemetrySenderConfig.h"

static NSString *const kTelemetryEndpointURL = @"https://dc.services.visualstudio.com/v2/track";

@implementation MSAITelemetrySenderConfig

-(instancetype)init{
  
  if ((self = [super init])) {
    
    self.endpointURL = kTelemetryEndpointURL;
  }
  return self;
}

@end
