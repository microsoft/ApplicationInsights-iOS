#import "MSAIPageViewData.h"
/// Data contract class for type PageViewData.
@implementation MSAIPageViewData

/// Initializes a new instance of the class.
- (instancetype)init {
  if(self = [super init]) {
  }
  return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
  MSAIOrderedDictionary *dict = [super serializeToDictionary];
  if(self.url != nil) {
    [dict setObject:self.url forKey:@"url"];
  }
  if(self.duration != nil) {
    [dict setObject:self.duration forKey:@"duration"];
  }
  if(self.referrer != nil) {
    [dict setObject:self.referrer forKey:@"referrer"];
  }
  if(self.referrerData != nil) {
    [dict setObject:self.referrerData forKey:@"referrerData"];
  }
  return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    self.url = [coder decodeObjectForKey:@"self.url"];
    self.duration = [coder decodeObjectForKey:@"self.duration"];
    self.referrer = [coder decodeObjectForKey:@"self.referrer"];
    self.referrerData = [coder decodeObjectForKey:@"self.referrerData"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:self.url forKey:@"self.url"];
  [coder encodeObject:self.duration forKey:@"self.duration"];
  [coder encodeObject:self.referrer forKey:@"self.referrer"];
  [coder encodeObject:self.referrerData forKey:@"self.referrerData"];
}

@end
