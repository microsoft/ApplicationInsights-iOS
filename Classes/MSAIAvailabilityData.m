#import "MSAIAvailabilityData.h"
/// Data contract class for type AvailabilityData.
@implementation MSAIAvailabilityData

/// Initializes a new instance of the class.
- (instancetype)init {
  if(self = [super init]) {
    self.version = @2;
    self.properties = [NSDictionary new];
    self.measurements = [NSDictionary new];
  }
  return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
  MSAIOrderedDictionary *dict = [super serializeToDictionary];
  if(self.testRunId != nil) {
    [dict setObject:self.testRunId forKey:@"testRunId"];
  }
  if(self.testTimeStamp != nil) {
    [dict setObject:self.testTimeStamp forKey:@"testTimeStamp"];
  }
  if(self.testName != nil) {
    [dict setObject:self.testName forKey:@"testName"];
  }
  if(self.duration != nil) {
    [dict setObject:self.duration forKey:@"duration"];
  }
  [dict setObject:[NSNumber numberWithInt:(int)self.result] forKey:@"result"];
  if(self.runLocation != nil) {
    [dict setObject:self.runLocation forKey:@"runLocation"];
  }
  if(self.message != nil) {
    [dict setObject:self.message forKey:@"message"];
  }
  if(self.dataSize != nil) {
    [dict setObject:self.dataSize forKey:@"dataSize"];
  }
  if(self.properties != nil) {
    [dict setObject:self.properties forKey:@"properties"];
  }
  if(self.measurements != nil) {
    [dict setObject:self.measurements forKey:@"measurements"];
  }
  return dict;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    self.testRunId = [coder decodeObjectForKey:@"self.testRunId"];
    self.testTimeStamp = [coder decodeObjectForKey:@"self.testTimeStamp"];
    self.testName = [coder decodeObjectForKey:@"self.testName"];
    self.duration = [coder decodeObjectForKey:@"self.duration"];
    self.result = [coder decodeObjectForKey:@"self.result"];
    self.runLocation = [coder decodeObjectForKey:@"self.runLocation"];
    self.message = [coder decodeObjectForKey:@"self.message"];
    self.dataSize = [coder decodeObjectForKey:@"self.dataSize"];
    self.measurements = [coder decodeObjectForKey:@"self.measurements"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:self.testRunId forKey:@"self.testRunId"];
  [coder encodeObject:self.testTimeStamp forKey:@"self.testTimeStamp"];
  [coder encodeObject:self.testName forKey:@"self.testName"];
  [coder encodeObject:self.duration forKey:@"self.duration"];
  [coder encodeObject:self.result forKey:@"self.result"];
  [coder encodeObject:self.runLocation forKey:@"self.runLocation"];
  [coder encodeObject:self.message forKey:@"self.message"];
  [coder encodeObject:self.dataSize forKey:@"self.dataSize"];
  [coder encodeObject:self.measurements forKey:@"self.measurements"];
}

@end
