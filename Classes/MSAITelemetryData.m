#import "MSAITelemetryData.h"

@implementation MSAITelemetryData

- (NSDictionary *)serializeToDictionary {
  NSMutableDictionary * dict = [super serializeToDictionary];
  if (self.version != nil) {
    [dict setObject:self.version forKey:@"ver"];
  }
  if (self.name != nil) {
    [dict setObject:self.name forKey:@"name"];
  }
  if (self.properties != nil) {
    [dict setObject:self.properties forKey:@"properties"];
  }
  return dict;	
}

@end
