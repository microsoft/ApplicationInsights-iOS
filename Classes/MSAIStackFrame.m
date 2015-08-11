#import "MSAIStackFrame.h"
#import "MSAIOrderedDictionary.h"

/// Data contract class for type StackFrame.
@implementation MSAIStackFrame

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
    MSAIOrderedDictionary *dict = [super serializeToDictionary];
    if (self.level != nil) {
        [dict setObject:self.level forKey:@"level"];
    }
    if (self.method != nil) {
        [dict setObject:self.method forKey:@"method"];
    }
    if (self.assembly != nil) {
        [dict setObject:self.assembly forKey:@"assembly"];
    }
    if (self.fileName != nil) {
        [dict setObject:self.fileName forKey:@"fileName"];
    }
    if (self.line != nil) {
        [dict setObject:self.line forKey:@"line"];
    }
    return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    _level = [coder decodeObjectForKey:@"self.level"];
    _method = [coder decodeObjectForKey:@"self.method"];
    _assembly = [coder decodeObjectForKey:@"self.assembly"];
    _fileName = [coder decodeObjectForKey:@"self.fileName"];
    _line = [coder decodeObjectForKey:@"self.line"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:self.level forKey:@"self.level"];
  [coder encodeObject:self.method forKey:@"self.method"];
  [coder encodeObject:self.assembly forKey:@"self.assembly"];
  [coder encodeObject:self.fileName forKey:@"self.fileName"];
  [coder encodeObject:self.line forKey:@"self.line"];
}


@end
