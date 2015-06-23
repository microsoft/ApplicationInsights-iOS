#import "MSAIUser.h"
#import "MSAIOrderedDictionary.h"

/// Data contract class for type User.
@implementation MSAIUser

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
    MSAIOrderedDictionary *dict = [super serializeToDictionary];
    if (self.accountAcquisitionDate != nil) {
        [dict setObject:self.accountAcquisitionDate forKey:@"ai.user.accountAcquisitionDate"];
    }
    if (self.accountId != nil) {
        [dict setObject:self.accountId forKey:@"ai.user.accountId"];
    }
    if (self.userAgent != nil) {
        [dict setObject:self.userAgent forKey:@"ai.user.userAgent"];
    }
    if (self.userId != nil) {
        [dict setObject:self.userId forKey:@"ai.user.id"];
    }
    return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    self.accountAcquisitionDate = [coder decodeObjectForKey:@"self.accountAcquisitionDate"];
    self.accountId = [coder decodeObjectForKey:@"self.accountId"];
    self.userAgent = [coder decodeObjectForKey:@"self.userAgent"];
    self.userId = [coder decodeObjectForKey:@"self.userId"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:self.accountAcquisitionDate forKey:@"self.accountAcquisitionDate"];
  [coder encodeObject:self.accountId forKey:@"self.accountId"];
  [coder encodeObject:self.userAgent forKey:@"self.userAgent"];
  [coder encodeObject:self.userId forKey:@"self.userId"];
}


@end
