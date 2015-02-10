#import "MSAIPageViewData.h"
/// Data contract class for type PageViewData.
@implementation MSAIPageViewData
@synthesize envelopeTypeName = _envelopeTypeName;
@synthesize dataTypeName = _dataTypeName;

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
        _envelopeTypeName = @"Microsoft.ApplicationInsights.PageView";
        _dataTypeName = @"PageViewData";
    }
    return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
    MSAIOrderedDictionary *dict = [super serializeToDictionary];
    if (self.url != nil) {
        [dict setObject:self.url forKey:@"url"];
    }
    if (self.duration != nil) {
        [dict setObject:self.duration forKey:@"duration"];
    }
    return dict;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    self.url = [coder decodeObjectForKey:@"self.url"];
    self.duration = [coder decodeObjectForKey:@"self.duration"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:self.url forKey:@"self.url"];
  [coder encodeObject:self.duration forKey:@"self.duration"];
}


@end
