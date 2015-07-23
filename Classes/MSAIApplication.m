#import "MSAIApplication.h"
/// Data contract class for type Application.
@implementation MSAIApplication

/// Initializes a new instance of the class.
- (instancetype)init {
  if(self = [super init]) {
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
    [dict setObject:self.version forKey:@"ai.application.ver"];
  }
  if(self.build != nil) {
    [dict setObject:self.build forKey:@"ai.application.build"];
  }
  if(self.typeId != nil) {
    [dict setObject:self.typeId forKey:@"ai.application.typeId"];
  }
  return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    self.build = [coder decodeObjectForKey:@"self.build"];
    self.typeId = [coder decodeObjectForKey:@"self.typeId"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:self.build forKey:@"self.build"];
  [coder encodeObject:self.typeId forKey:@"self.typeId"];
}

@end
