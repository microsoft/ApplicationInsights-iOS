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
        self.properties = [MSAIOrderedDictionary new];
        self.measurements = [MSAIOrderedDictionary new];
    }
    return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
    MSAIOrderedDictionary *dict = [super serializeToDictionary];
    if (self.requestDataId != nil) {
        [dict setObject:self.requestDataId forKey:@"id"];
    }
    if (self.name != nil) {
        [dict setObject:self.name forKey:@"name"];
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
    [dict setObject:self.properties forKey:@"properties"];
    [dict setObject:self.measurements forKey:@"measurements"];
    return dict;
}

@end
