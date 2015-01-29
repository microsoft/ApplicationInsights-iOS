#import "MSAIDataPoint.h"

/// Data contract class for type DataPoint.
@implementation MSAIDataPoint

/// Initializes a new instance of the class.
- (instancetype)init {
  if(self = [super init]) {
    self.kind = MSAIDataPointType_measurement;
  }
  return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
  MSAIOrderedDictionary *dict = [super serializeToDictionary];
  if(self.name != nil) {
    [dict setObject:self.name forKey:@"name"];
  }
  dict[@"kind"] = @((int) self.kind);
  if(self.value != nil) {
    dict[@"value"] = self.value;
  }
  if(self.count != nil) {
    dict[@"count"] = self.count;
  }
  if(self.min != nil) {
    dict[@"min"] = self.min;
  }
  if(self.max != nil) {
    dict[@"max"] = self.max;
  }
  if(self.stdDev != nil) {
    dict[@"stdDev"] = self.stdDev;
  }
  return dict;
}

@end
