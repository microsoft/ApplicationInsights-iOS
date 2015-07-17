#import "MSAIRequestData.h"
#import "MSAIOrderedDictionary.h"

/// Data contract class for type RequestData.
@implementation MSAIRequestData

@synthesize envelopeTypeName = _envelopeTypeName;
@synthesize dataTypeName = _dataTypeName;
@synthesize version = _version;
@synthesize properties = _properties;

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
        _envelopeTypeName = @"Microsoft.ApplicationInsights.Request";
        _dataTypeName = @"RequestData";
        _version = @2;
        _properties = [MSAIOrderedDictionary new];
        _measurements = [MSAIOrderedDictionary new];
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

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    _requestDataId = [coder decodeObjectForKey:@"self.requestDataId"];
    _startTime = [coder decodeObjectForKey:@"self.startTime"];
    _duration = [coder decodeObjectForKey:@"self.duration"];
    _responseCode = [coder decodeObjectForKey:@"self.responseCode"];
    _success = [coder decodeBoolForKey:@"self.success"];
    _httpMethod = [coder decodeObjectForKey:@"self.httpMethod"];
    _url = [coder decodeObjectForKey:@"self.url"];
    _measurements = [coder decodeObjectForKey:@"self.measurements"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:self.requestDataId forKey:@"self.requestDataId"];
  [coder encodeObject:self.startTime forKey:@"self.startTime"];
  [coder encodeObject:self.duration forKey:@"self.duration"];
  [coder encodeObject:self.responseCode forKey:@"self.responseCode"];
  [coder encodeBool:self.success forKey:@"self.success"];
  [coder encodeObject:self.httpMethod forKey:@"self.httpMethod"];
  [coder encodeObject:self.url forKey:@"self.url"];
  [coder encodeObject:self.measurements forKey:@"self.measurements"];
}


@end
