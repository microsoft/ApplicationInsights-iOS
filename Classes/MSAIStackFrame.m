#import "MSAIStackFrame.h"
/// Data contract class for type StackFrame.
@implementation MSAIStackFrame

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

@end
