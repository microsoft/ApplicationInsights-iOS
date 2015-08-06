#import "MSAIExceptionData.h"
#import "MSAIOrderedDictionary.h"
#import "MSAIEnums.h"
#import "MSAIExceptionDetails.h"

/// Data contract class for type ExceptionData.
@implementation MSAIExceptionData
@synthesize envelopeTypeName = _envelopeTypeName;
@synthesize dataTypeName = _dataTypeName;
@synthesize version = _version;
@synthesize properties = _properties;

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
        _envelopeTypeName = @"Microsoft.ApplicationInsights.Exception";
        _dataTypeName = @"ExceptionData";
        _version = @2;
        _exceptions = [NSMutableArray new];
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
    if (self.handledAt != nil) {
        [dict setObject:self.handledAt forKey:@"handledAt"];
    }
    if (self.problemId != nil) {
      [dict setObject:self.problemId forKey:@"problemId"];
    }
    if (self.crashThreadId != nil) {
      [dict setObject:self.crashThreadId forKey:@"crashThreadId"];
    }
    if (self.exceptions != nil) {
        NSMutableArray *exceptionsArray = [NSMutableArray array];
        for (MSAIExceptionDetails *exceptionsElement in self.exceptions) {
            [exceptionsArray addObject:[exceptionsElement serializeToDictionary]];
        }
        [dict setObject:exceptionsArray forKey:@"exceptions"];
    }
  [dict setObject:@((int) self.severityLevel) forKey:@"severityLevel"];
  if(self.problemId != nil) {
    [dict setObject:self.problemId forKey:@"problemId"];
  }
  if(self.crashThreadId != nil) {
    [dict setObject:self.crashThreadId forKey:@"crashThreadId"];
  }
    [dict setObject:self.properties forKey:@"properties"];
    [dict setObject:self.measurements forKey:@"measurements"];
    return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    _handledAt = [coder decodeObjectForKey:@"self.handledAt"];
    _exceptions = [coder decodeObjectForKey:@"self.exceptions"];
    _severityLevel = (MSAISeverityLevel) [coder decodeIntForKey:@"self.severityLevel"];
    _problemId = [coder decodeObjectForKey:@"self.problemId"];
    _crashThreadId = [coder decodeObjectForKey:@"self.crashThreadId"];
    _measurements = [coder decodeObjectForKey:@"self.measurements"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:self.handledAt forKey:@"self.handledAt"];
  [coder encodeObject:self.exceptions forKey:@"self.exceptions"];
  [coder encodeInt:self.severityLevel forKey:@"self.severityLevel"];
  [coder encodeObject:self.problemId forKey:@"self.problemId"];
  [coder encodeObject:self.crashThreadId forKey:@"self.crashThreadId"];
  [coder encodeObject:self.measurements forKey:@"self.measurements"];
}


@end
