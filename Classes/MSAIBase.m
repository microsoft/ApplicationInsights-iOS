#import "MSAIBase.h"
/// Data contract class for type Base.
@implementation MSAIBase

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
    if (self.baseType != nil) {
        [dict setObject:self.baseType forKey:@"baseType"];
    }
    return dict;
}

@end
