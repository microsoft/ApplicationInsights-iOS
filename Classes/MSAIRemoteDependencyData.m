#import "MSAIRemoteDependencyData.h"
/// Data contract class for type RemoteDependencyData.
@implementation MSAIRemoteDependencyData
@synthesize envelopeTypeName = _envelopeTypeName;
@synthesize dataTypeName = _dataTypeName;

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
        _envelopeTypeName = @"Microsoft.ApplicationInsights.RemoteDependency";
        _dataTypeName = @"RemoteDependencyData";
        self.version = [NSNumber numberWithInt:2];
        self.kind = MSAIDataPointType_measurement;
        self.dependencyKind = MSAIDependencyKind_undefined;
        self.success = true;
        self.dependencySource = MSAIDependencySourceType_undefined;
    }
    return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (NSMutableDictionary *)serializeToDictionary {
    NSMutableDictionary * dict = [super serializeToDictionary];
    [dict setObject:[NSNumber numberWithInt:(int)self.kind] forKey:@"kind"];
    if (self.value != nil) {
        [dict setObject:self.value forKey:@"value"];
    }
    if (self.count != nil) {
        [dict setObject:self.count forKey:@"count"];
    }
    if (self.min != nil) {
        [dict setObject:self.min forKey:@"min"];
    }
    if (self.max != nil) {
        [dict setObject:self.max forKey:@"max"];
    }
    if (self.stdDev != nil) {
        [dict setObject:self.stdDev forKey:@"stdDev"];
    }
    [dict setObject:[NSNumber numberWithInt:(int)self.dependencyKind] forKey:@"dependencyKind"];
    NSString *strsuccess = [NSString stringWithFormat:@"%s", (self.success) ? "true" : "false"];
    [dict setObject:strsuccess forKey:@"success"];
    NSString *strasync = [NSString stringWithFormat:@"%s", (self.async) ? "true" : "false"];
    [dict setObject:strasync forKey:@"async"];
    [dict setObject:[NSNumber numberWithInt:(int)self.dependencySource] forKey:@"dependencySource"];
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
