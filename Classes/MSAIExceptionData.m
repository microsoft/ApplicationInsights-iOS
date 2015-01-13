#import "MSAIExceptionData.h"
/// Data contract class for type ExceptionData.
@implementation MSAIExceptionData

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
        _envelopeTypeName = @"Microsoft.ApplicationInsights.Exception";
        _dataTypeName = @"ExceptionData";
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
    if (self.handledAt != nil) {
        [dict setObject:self.handledAt forKey:@"handledAt"];
    }
    if (self.exceptions != nil) {
        [dict setObject:self.exceptions forKey:@"exceptions"];
    }
    NSString *strseverityLevel = [NSString stringWithFormat:@"%d", (int)self.severityLevel];
    [dict setObject:strseverityLevel forKey:@"severityLevel"];
    if (self.properties != nil) {
        [dict setObject:self.properties forKey:@"properties"];
    }
    if (self.measurements != nil) {
        [dict setObject:self.measurements forKey:@"measurements"];
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
