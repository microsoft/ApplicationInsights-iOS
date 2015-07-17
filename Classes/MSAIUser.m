#import "MSAIUser.h"
#import "MSAIOrderedDictionary.h"

/// Data contract class for type User.
@implementation MSAIUser

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
    if(self.storeRegion != nil) {
        [dict setObject:self.storeRegion forKey:@"ai.user.storeRegion"];
    }
    return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    _accountAcquisitionDate = [coder decodeObjectForKey:@"self.accountAcquisitionDate"];
    _accountId = [coder decodeObjectForKey:@"self.accountId"];
    _userAgent = [coder decodeObjectForKey:@"self.userAgent"];
    _userId = [coder decodeObjectForKey:@"self.userId"];
    self.storeRegion = [coder decodeObjectForKey:@"self.storeRegion"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:self.accountAcquisitionDate forKey:@"self.accountAcquisitionDate"];
  [coder encodeObject:self.accountId forKey:@"self.accountId"];
  [coder encodeObject:self.userAgent forKey:@"self.userAgent"];
  [coder encodeObject:self.userId forKey:@"self.userId"];
  [coder encodeObject:self.storeRegion forKey:@"self.storeRegion"];
}


@end
