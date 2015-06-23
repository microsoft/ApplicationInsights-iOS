#import "MSAIMessageData.h"
#import "MSAIOrderedDictionary.h"
#import "MSAIEnums.h"

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
  
  if(self.properties){
    [dict setObject:self.properties forKey:@"properties"];
  }
  return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    self.message = [coder decodeObjectForKey:@"self.message"];
    self.severityLevel = (MSAISeverityLevel) [coder decodeIntForKey:@"self.severityLevel"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:self.message forKey:@"self.message"];
  [coder encodeInt:self.severityLevel forKey:@"self.severityLevel"];
}


@end
