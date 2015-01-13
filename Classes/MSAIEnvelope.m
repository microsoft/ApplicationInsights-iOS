#import "MSAIEnvelope.h"
/// Data contract class for type Envelope.
@implementation MSAIEnvelope

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
        self.version = [NSNumber numberWithInt:1];
        self.sampleRate = [NSNumber numberWithDouble:100.0];
    }
    return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (void)addToDictionary:(NSMutableDictionary *) dict {
    if (self.version != nil) {
        [dict setObject:self.version forKey:@"ver"];
    }
    if (self.name != nil) {
        [dict setObject:self.name forKey:@"name"];
    }
    if (self.time != nil) {
        [dict setObject:self.time forKey:@"time"];
    }
    if (self.sampleRate != nil) {
        [dict setObject:self.sampleRate forKey:@"sampleRate"];
    }
    if (self.seq != nil) {
        [dict setObject:self.seq forKey:@"seq"];
    }
    if (self.iKey != nil) {
        [dict setObject:self.iKey forKey:@"iKey"];
    }
    if (self.flags != nil) {
        [dict setObject:self.flags forKey:@"flags"];
    }
    if (self.deviceId != nil) {
        [dict setObject:self.deviceId forKey:@"deviceId"];
    }
    if (self.os != nil) {
        [dict setObject:self.os forKey:@"os"];
    }
    if (self.osVer != nil) {
        [dict setObject:self.osVer forKey:@"osVer"];
    }
    if (self.appId != nil) {
        [dict setObject:self.appId forKey:@"appId"];
    }
    if (self.appVer != nil) {
        [dict setObject:self.appVer forKey:@"appVer"];
    }
    if (self.userId != nil) {
        [dict setObject:self.userId forKey:@"userId"];
    }
    if (self.tags != nil) {
        [dict setObject:self.tags forKey:@"tags"];
    }
    NSString *strdata;
    if ([NSJSONSerialization isValidJSONObject:selfdata]) {
        strdata = [NSString stringWithFormat:@"%@", [self.data serialize]];
    }
    [dict setObject:strdata forKey:@"data"];
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
