#import "MSAIRemoteDependencyData.h"
/// Data contract class for type RemoteDependencyData.
@implementation MSAIRemoteDependencyData

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
- (void)addToDictionary:(NSMutableDictionary *) dict {
    if (self.version != nil) {
        [dict setObject:self.version forKey:@"ver"];
    }
    if (self.name != nil) {
        [dict setObject:self.name forKey:@"name"];
    }
    NSString *strkind = [NSString stringWithFormat:@"%d", (int)self.kind];
    [dict setObject:strkind forKey:@"kind"];
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
    NSString *strdependencyKind = [NSString stringWithFormat:@"%d", (int)self.dependencyKind];
    [dict setObject:strdependencyKind forKey:@"dependencyKind"];
    NSString *strsuccess = [NSString stringWithFormat:@"%s", (self.success) ? "true" : "false"];
    [dict setObject:strsuccess forKey:@"success"];
    NSString *strasync = [NSString stringWithFormat:@"%s", (self.async) ? "true" : "false"];
    [dict setObject:strasync forKey:@"async"];
    NSString *strdependencySource = [NSString stringWithFormat:@"%d", (int)self.dependencySource];
    [dict setObject:strdependencySource forKey:@"dependencySource"];
    if (self.properties != nil) {
        [dict setObject:self.properties forKey:@"properties"];
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
