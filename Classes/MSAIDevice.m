#import "MSAIDevice.h"
/// Data contract class for type Device.
@implementation MSAIDevice

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
    if (self.deviceId != nil) {
        [dict setObject:self.deviceId forKey:@"id"];
    }
    if (self.ip != nil) {
        [dict setObject:self.ip forKey:@"ip"];
    }
    if (self.language != nil) {
        [dict setObject:self.language forKey:@"language"];
    }
    if (self.locale != nil) {
        [dict setObject:self.locale forKey:@"locale"];
    }
    if (self.model != nil) {
        [dict setObject:self.model forKey:@"model"];
    }
    if (self.network != nil) {
        [dict setObject:self.network forKey:@"network"];
    }
    if (self.oemName != nil) {
        [dict setObject:self.oemName forKey:@"oemName"];
    }
    if (self.os != nil) {
        [dict setObject:self.os forKey:@"os"];
    }
    if (self.osVersion != nil) {
        [dict setObject:self.osVersion forKey:@"osVersion"];
    }
    if (self.roleInstance != nil) {
        [dict setObject:self.roleInstance forKey:@"roleInstance"];
    }
    if (self.roleName != nil) {
        [dict setObject:self.roleName forKey:@"roleName"];
    }
    if (self.screenResolution != nil) {
        [dict setObject:self.screenResolution forKey:@"screenResolution"];
    }
    if (self.type != nil) {
        [dict setObject:self.type forKey:@"type"];
    }
    if (self.vmName != nil) {
        [dict setObject:self.vmName forKey:@"vmName"];
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
