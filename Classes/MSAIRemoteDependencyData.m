#import "MSAIRemoteDependencyData.h"
/// Data contract class for type RemoteDependencyData.
@implementation MSAIRemoteDependencyData
@synthesize envelopeTypeName = _envelopeTypeName;
@synthesize dataTypeName = _dataTypeName;

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
        _envelopeTypeName = @"Microsoft.ApplicationInsights.RemoteDependency";
        _dataTypeName = @"RemoteDependencyData";
        self.version = @2;
        self.kind = MSAIDataPointType_measurement;
        self.dependencyKind = MSAIDependencyKind_undefined;
        self.success = true;
        self.dependencySource = MSAIDependencySourceType_undefined;
        self.properties = [MSAIOrderedDictionary new];
    }
    return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
    MSAIOrderedDictionary *dict = [super serializeToDictionary];
    if (self.name != nil) {
        [dict setObject:self.name forKey:@"name"];
    }
  [dict setObject:@((int) self.kind) forKey:@"kind"];
    if (self.value != nil) {
        [dict setObject:self.value forKey:@"value"];
    }
    if (self.count != nil) {
        [dict setObject:self.count forKey:@"count"];
    }
    if (self.min != nil) {
        [dict setObject:self.min forKey:@"min"];
    }
    if (self.max != nil) {
        [dict setObject:self.max forKey:@"max"];
    }
    if (self.stdDev != nil) {
        [dict setObject:self.stdDev forKey:@"stdDev"];
    }
  [dict setObject:@((int) self.dependencyKind) forKey:@"dependencyKind"];
    NSString *strsuccess = [NSString stringWithFormat:@"%s", (self.success) ? "true" : "false"];
    [dict setObject:strsuccess forKey:@"success"];
    NSString *strasync = [NSString stringWithFormat:@"%s", (self.async) ? "true" : "false"];
    [dict setObject:strasync forKey:@"async"];
  [dict setObject:@((int) self.dependencySource) forKey:@"dependencySource"];
    [dict setObject:self.properties forKey:@"properties"];
    return dict;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    self.kind = (MSAIDataPointType) [coder decodeIntForKey:@"self.kind"];
    self.value = [coder decodeObjectForKey:@"self.value"];
    self.count = [coder decodeObjectForKey:@"self.count"];
    self.min = [coder decodeObjectForKey:@"self.min"];
    self.max = [coder decodeObjectForKey:@"self.max"];
    self.stdDev = [coder decodeObjectForKey:@"self.stdDev"];
    self.dependencyKind = (MSAIDependencyKind) [coder decodeIntForKey:@"self.dependencyKind"];
    self.success = [coder decodeBoolForKey:@"self.success"];
    self.async = [coder decodeBoolForKey:@"self.async"];
    self.dependencySource = (MSAIDependencySourceType) [coder decodeIntForKey:@"self.dependencySource"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeInt:self.kind forKey:@"self.kind"];
  [coder encodeObject:self.value forKey:@"self.value"];
  [coder encodeObject:self.count forKey:@"self.count"];
  [coder encodeObject:self.min forKey:@"self.min"];
  [coder encodeObject:self.max forKey:@"self.max"];
  [coder encodeObject:self.stdDev forKey:@"self.stdDev"];
  [coder encodeInt:self.dependencyKind forKey:@"self.dependencyKind"];
  [coder encodeBool:self.success forKey:@"self.success"];
  [coder encodeBool:self.async forKey:@"self.async"];
  [coder encodeInt:self.dependencySource forKey:@"self.dependencySource"];
}


@end
