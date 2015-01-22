#import "MSAITelemetryData.h"

@implementation MSAITelemetryData

- (MSAIOrderedDictionary *)serializeToDictionary {
  MSAIOrderedDictionary *dict = [super serializeToDictionary];
  if (self.version != nil) {
    [dict setObject:self.version forKey:@"ver"];
  }
  
  return dict;	
}

@end
