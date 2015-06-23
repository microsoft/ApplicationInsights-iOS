#import "MSAIInternal.h"
#import "MSAIOrderedDictionary.h"

/// Data contract class for type Internal.
@implementation MSAIInternal

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
    MSAIOrderedDictionary *dict = [super serializeToDictionary];
    if (self.sdkVersion != nil) {
        [dict setObject:self.sdkVersion forKey:@"ai.internal.sdkVersion"];
    }
    if (self.agentVersion != nil) {
        [dict setObject:self.agentVersion forKey:@"ai.internal.agentVersion"];
    }
    return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super init];
  if(self) {
    self.sdkVersion = [coder decodeObjectForKey:@"self.sdkVersion"];
    self.agentVersion = [coder decodeObjectForKey:@"self.agentVersion"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeObject:self.sdkVersion forKey:@"self.sdkVersion"];
  [coder encodeObject:self.agentVersion forKey:@"self.agentVersion"];
}


@end
