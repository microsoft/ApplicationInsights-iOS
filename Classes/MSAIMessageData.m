#import "MSAIMessageData.h"
/// Data contract class for type MessageData.
@implementation MSAIMessageData
@synthesize envelopeTypeName = _envelopeTypeName;
@synthesize dataTypeName = _dataTypeName;

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
        _envelopeTypeName = @"Microsoft.ApplicationInsights.Message";
        _dataTypeName = @"MessageData";
        self.version = @2;
        self.properties = [MSAIOrderedDictionary new];
    }
    return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
    MSAIOrderedDictionary *dict = [super serializeToDictionary];
    if (self.message != nil) {
        [dict setObject:self.message forKey:@"message"];
    }
  [dict setObject:@((int) self.severityLevel) forKey:@"severityLevel"];
    [dict setObject:self.properties forKey:@"properties"];
    return dict;
}

@end
