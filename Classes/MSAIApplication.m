#import "MSAIApplication.h"
/// Data contract class for type Application.
@implementation MSAIApplication

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
    if (self.version != nil) {
        [dict setObject:self.version forKey:@"ai.application.ver"];
    }
    return dict;
}

@end
