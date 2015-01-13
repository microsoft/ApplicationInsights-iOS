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
- (void)addToDictionary:(NSMutableDictionary *) dict {
    if (self.sessionId != nil) {
        [dict setObject:self.sessionId forKey:@"id"];
    }
    if (self.isFirst != nil) {
        [dict setObject:self.isFirst forKey:@"isFirst"];
    }
    if (self.isNew != nil) {
        [dict setObject:self.isNew forKey:@"isNew"];
    }
}

///
/// Serializes the object to a string in json format.
/// @param writer The writer to serialize this object to.
///
- (NSString *)serialize {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [self addToDictionary: dict];
    NSMutableString  *jsonString;
    NSError *error = nil;
    NSData *json;
    json = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    jsonString = [[NSMutableString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
