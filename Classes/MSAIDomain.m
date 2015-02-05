#import "MSAIDomain.h"
/// Data contract class for type Domain.
@implementation MSAIDomain
@synthesize envelopeTypeName = _envelopeTypeName;
@synthesize dataTypeName = _dataTypeName;

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
        _envelopeTypeName = @"Microsoft.ApplicationInsights.Do";
        _dataTypeName = @"Domain";
    }
    return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
    MSAIOrderedDictionary *dict = [super serializeToDictionary];
    return dict;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    _envelopeTypeName = [coder decodeObjectForKey:@"_envelopeTypeName"];
    _dataTypeName = [coder decodeObjectForKey:@"_dataTypeName"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:_envelopeTypeName forKey:@"_envelopeTypeName"];
  [coder encodeObject:_dataTypeName forKey:@"_dataTypeName"];
}


@end
