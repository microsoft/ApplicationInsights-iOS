#import "MSAIMetricData.h"
/// Data contract class for type MetricData.
@implementation MSAIMetricData

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
        _envelopeTypeName = @"Microsoft.ApplicationInsights.Metric";
        _dataTypeName = @"MetricData";
        self.version = [NSNumber numberWithInt:2];
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
    if (self.metrics != nil) {
        [dict setObject:self.metrics forKey:@"metrics"];
    }
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
