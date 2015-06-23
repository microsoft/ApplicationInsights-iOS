#import "MSAISessionStateData.h"
#import "MSAIOrderedDictionary.h"

/// Data contract class for type SessionStateData.
@implementation MSAISessionStateData
@synthesize envelopeTypeName = _envelopeTypeName;
@synthesize dataTypeName = _dataTypeName;
@synthesize version = _version;

/// Initializes a new instance of the class.
- (instancetype)init {
  if(self = [super init]) {
    _envelopeTypeName = @"Microsoft.ApplicationInsights.SessionState";
    _dataTypeName = @"SessionStateData";
    _version = @2;
    _state = MSAISessionState_start;
  }
  return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
  MSAIOrderedDictionary *dict = [super serializeToDictionary];
  [dict setObject:[NSNumber numberWithInt:(int)self.state] forKey:@"state"];
  return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    _envelopeTypeName =[coder decodeObjectForKey:@"envelopeTypeName"];
    _dataTypeName = [coder decodeObjectForKey:@"dataTypeName"];
    _state = (MSAISessionState)[coder decodeIntForKey:@"self.state"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:self.envelopeTypeName forKey:@"envelopeTypeName"];
  [coder encodeObject:self.dataTypeName forKey:@"dataTypeName"];
  [coder encodeInt:self.state forKey:@"self.state"];
}

@end
