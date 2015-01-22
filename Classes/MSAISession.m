#import "MSAISession.h"
/// Data contract class for type Session.
@implementation MSAISession

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
    if (self.sessionId != nil) {
        [dict setObject:self.sessionId forKey:@"ai.session.id"];
    }
    if (self.isFirst != nil) {
        [dict setObject:self.isFirst forKey:@"ai.session.isFirst"];
    }
    if (self.isNew != nil) {
        [dict setObject:self.isNew forKey:@"ai.session.isNew"];
    }
    return dict;
}

@end
