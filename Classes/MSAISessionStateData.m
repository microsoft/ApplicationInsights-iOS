#import "MSAISessionStateData.h"
/// Data contract class for type SessionStateData.
@implementation MSAISessionStateData

/// Initializes a new instance of the class.
- (instancetype)init {
  if(self = [super init]) {
    self.version = @2;
    self.state = MSAISessionState_start;
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
    self.state = (MSAISessionState)[coder decodeIntForKey:@"self.state"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeInt:self.state forKey:@"self.state"];
}

@end
