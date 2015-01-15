#import "MSAIUser.h"
/// Data contract class for type User.
@implementation MSAIUser

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
- (NSMutableDictionary *)serializeToDictionary {
    NSMutableDictionary * dict = [super serializeToDictionary];
    if (self.accountAcquisitionDate != nil) {
        [dict setObject:self.accountAcquisitionDate forKey:@"accountAcquisitionDate"];
    }
    if (self.accountId != nil) {
        [dict setObject:self.accountId forKey:@"accountId"];
    }
    if (self.userAgent != nil) {
        [dict setObject:self.userAgent forKey:@"userAgent"];
    }
    if (self.userId != nil) {
        [dict setObject:self.userId forKey:@"id"];
    }
    return dict;
}

///
/// Serializes the object to a string in json format.
/// @param writer The writer to serialize this object to.
///
- (NSString *)serializeToString {
    NSMutableDictionary *dict = [self serializeToDictionary];
    NSMutableString  *jsonString;
    NSError *error = nil;
    NSData *json;
    json = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    jsonString = [[NSMutableString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
