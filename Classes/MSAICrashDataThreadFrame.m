#import "MSAICrashDataThreadFrame.h"
#import "MSAIOrderedDictionary.h"

/// Data contract class for type CrashDataThreadFrame.
@implementation MSAICrashDataThreadFrame

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
        self.registers = [MSAIOrderedDictionary new];
    }
    return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
    MSAIOrderedDictionary *dict = [super serializeToDictionary];
    if (self.address != nil) {
        [dict setObject:self.address forKey:@"address"];
    }
  // symbol is not needed
//    if (self.symbol != nil) {
//        [dict setObject:self.symbol forKey:@"symbol"];
//    }
    if (self.registers != nil && self.registers.count > 0) {
        [dict setObject:self.registers forKey:@"registers"];
    }
    return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    self.address = [coder decodeObjectForKey:@"self.address"];
    self.symbol = [coder decodeObjectForKey:@"self.symbol"];
    self.registers = [coder decodeObjectForKey:@"self.registers"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:self.address forKey:@"self.address"];
  [coder encodeObject:self.symbol forKey:@"self.symbol"];
  [coder encodeObject:self.registers forKey:@"self.registers"];
}


@end
