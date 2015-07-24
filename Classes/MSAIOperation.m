#import "MSAIOperation.h"
/// Data contract class for type Operation.
@implementation MSAIOperation

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
  if(self.operationId != nil) {
    [dict setObject:self.operationId forKey:@"ai.operation.id"];
  }
  if(self.name != nil) {
    [dict setObject:self.name forKey:@"ai.operation.name"];
  }
  if(self.parentId != nil) {
    [dict setObject:self.parentId forKey:@"ai.operation.parentId"];
  }
  if(self.rootId != nil) {
    [dict setObject:self.rootId forKey:@"ai.operation.rootId"];
  }
  if(self.syntheticSource != nil) {
    [dict setObject:self.syntheticSource forKey:@"ai.operation.syntheticSource"];
  }
  if(self.isSynthetic != nil) {
    [dict setObject:self.isSynthetic forKey:@"ai.operation.isSynthetic"];
  }
  return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    self.operationId = [coder decodeObjectForKey:@"self.operationId"];
    self.parentId = [coder decodeObjectForKey:@"self.parentId"];
    self.rootId = [coder decodeObjectForKey:@"self.rootId"];
    self.syntheticSource = [coder decodeObjectForKey:@"self.syntheticSource"];
    self.isSynthetic = [coder decodeObjectForKey:@"self.isSynthetic"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:self.operationId forKey:@"self.operationId"];
  [coder encodeObject:self.parentId forKey:@"self.parentId"];
  [coder encodeObject:self.rootId forKey:@"self.rootId"];
  [coder encodeObject:self.syntheticSource forKey:@"self.syntheticSource"];
  [coder encodeObject:self.isSynthetic forKey:@"self.isSynthetic"];
}

@end
