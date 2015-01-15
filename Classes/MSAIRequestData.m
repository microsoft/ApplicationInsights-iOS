#import "MSAIRequestData.h"
/// Data contract class for type RequestData.
@implementation MSAIRequestData
@synthesize envelopeTypeName = _envelopeTypeName;
@synthesize dataTypeName = _dataTypeName;

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
        _envelopeTypeName = @"Microsoft.ApplicationInsights.Request";
        _dataTypeName = @"RequestData";
        self.version = [NSNumber numberWithInt:2];
    }
    return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (NSMutableDictionary *)serializeToDictionary {
    NSMutableDictionary * dict = [super serializeToDictionary];
    if (self.requestDataId != nil) {
        [dict setObject:self.requestDataId forKey:@"id"];
    }
    if (self.startTime != nil) {
        [dict setObject:self.startTime forKey:@"startTime"];
    }
    if (self.duration != nil) {
        [dict setObject:self.duration forKey:@"duration"];
    }
    if (self.responseCode != nil) {
        [dict setObject:self.responseCode forKey:@"responseCode"];
    }
    NSString *strsuccess = [NSString stringWithFormat:@"%s", (self.success) ? "true" : "false"];
    [dict setObject:strsuccess forKey:@"success"];
    if (self.httpMethod != nil) {
        [dict setObject:self.httpMethod forKey:@"httpMethod"];
    }
    if (self.url != nil) {
        [dict setObject:self.url forKey:@"url"];
    }
    if (self.measurements != nil) {
        [dict setObject:self.measurements forKey:@"measurements"];
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
