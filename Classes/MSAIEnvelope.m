#import "MSAIEnvelope.h"

/// Data contract class for type Envelope.
@implementation MSAIEnvelope

/// Initializes a new instance of the class.
- (instancetype)init {
  if(self = [super init]) {
    self.version = @1;
    self.sampleRate = @100.0;
    self.tags = [MSAIOrderedDictionary new];
  }
  return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
  MSAIOrderedDictionary *dict = [super serializeToDictionary];
  if(self.version != nil) {
    [dict setObject:self.version forKey:@"ver"];
  }
  if(self.name != nil) {
    [dict setObject:self.name forKey:@"name"];
  }
  if(self.time != nil) {
    [dict setObject:self.time forKey:@"time"];
  }
  if(self.sampleRate != nil) {
    [dict setObject:self.sampleRate forKey:@"sampleRate"];
  }
  if(self.seq != nil) {
    [dict setObject:self.seq forKey:@"seq"];
  }
  if(self.iKey != nil) {
    [dict setObject:self.iKey forKey:@"iKey"];
  }
  if(self.flags != nil) {
    [dict setObject:self.flags forKey:@"flags"];
  }
  if(self.deviceId != nil) {
    [dict setObject:self.deviceId forKey:@"deviceId"];
  }
  if(self.os != nil) {
    [dict setObject:self.os forKey:@"os"];
  }
  if(self.osVer != nil) {
    [dict setObject:self.osVer forKey:@"osVer"];
  }
  if(self.appId != nil) {
    [dict setObject:self.appId forKey:@"appId"];
  }
  if(self.appVer != nil) {
    [dict setObject:self.appVer forKey:@"appVer"];
  }
  if(self.userId != nil) {
    [dict setObject:self.userId forKey:@"userId"];
  }
  [dict setObject:self.tags forKey:@"tags"];
  
  MSAIOrderedDictionary *dataDict = [self.data serializeToDictionary];
  if ([NSJSONSerialization isValidJSONObject:dataDict]) {
    [dict setObject:dataDict forKey:@"data"];
  }
  return dict;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
  self = [super init];
  if(self) {
    self.version = [coder decodeObjectForKey:@"self.version"];
    self.name = [coder decodeObjectForKey:@"self.name"];
    self.time = [coder decodeObjectForKey:@"self.time"];
    self.sampleRate = [coder decodeObjectForKey:@"self.sampleRate"];
    self.seq = [coder decodeObjectForKey:@"self.seq"];
    self.iKey = [coder decodeObjectForKey:@"self.iKey"];
    self.flags = [coder decodeObjectForKey:@"self.flags"];
    self.deviceId = [coder decodeObjectForKey:@"self.deviceId"];
    self.os = [coder decodeObjectForKey:@"self.os"];
    self.osVer = [coder decodeObjectForKey:@"self.osVer"];
    self.appId = [coder decodeObjectForKey:@"self.appId"];
    self.appVer = [coder decodeObjectForKey:@"self.appVer"];
    self.userId = [coder decodeObjectForKey:@"self.userId"];
    self.tags = [coder decodeObjectForKey:@"self.tags"];
    self.data = [coder decodeObjectForKey:@"self.data"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeObject:self.version forKey:@"self.version"];
  [coder encodeObject:self.name forKey:@"self.name"];
  [coder encodeObject:self.time forKey:@"self.time"];
  [coder encodeObject:self.sampleRate forKey:@"self.sampleRate"];
  [coder encodeObject:self.seq forKey:@"self.seq"];
  [coder encodeObject:self.iKey forKey:@"self.iKey"];
  [coder encodeObject:self.flags forKey:@"self.flags"];
  [coder encodeObject:self.deviceId forKey:@"self.deviceId"];
  [coder encodeObject:self.os forKey:@"self.os"];
  [coder encodeObject:self.osVer forKey:@"self.osVer"];
  [coder encodeObject:self.appId forKey:@"self.appId"];
  [coder encodeObject:self.appVer forKey:@"self.appVer"];
  [coder encodeObject:self.userId forKey:@"self.userId"];
  [coder encodeObject:self.tags forKey:@"self.tags"];
  [coder encodeObject:self.data forKey:@"self.data"];
}


@end
