#import "MSAIUser.h"
/// Data contract class for type User.
@implementation MSAIUser

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
  if(self.accountAcquisitionDate != nil) {
    [dict setObject:self.accountAcquisitionDate forKey:@"ai.user.accountAcquisitionDate"];
  }
  if(self.accountId != nil) {
    [dict setObject:self.accountId forKey:@"ai.user.accountId"];
  }
  if(self.userAgent != nil) {
    [dict setObject:self.userAgent forKey:@"ai.user.userAgent"];
  }
  if(self.userId != nil) {
    [dict setObject:self.userId forKey:@"ai.user.id"];
  }
  if(self.storeRegion != nil) {
    [dict setObject:self.storeRegion forKey:@"ai.user.storeRegion"];
  }
  if(self.authUserId != nil) {
    [dict setObject:self.authUserId forKey:@"ai.user.authUserId"];
  }
  if(self.anonUserAcquisitionDate != nil) {
    [dict setObject:self.anonUserAcquisitionDate forKey:@"ai.user.anonUserAcquisitionDate"];
  }
  if(self.authUserAcquisitionDate != nil) {
    [dict setObject:self.authUserAcquisitionDate forKey:@"ai.user.authUserAcquisitionDate"];
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
    self.storeRegion = [coder decodeObjectForKey:@"self.storeRegion"];
    self.authUserId = [coder decodeObjectForKey:@"self.authUserId"];
    self.anonUserAcquisitionDate = [coder decodeObjectForKey:@"self.anonUserAcquisitionDate"];
    self.authUserAcquisitionDate = [coder decodeObjectForKey:@"self.authUserAcquisitionDate"];
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
  [coder encodeObject:self.authUserId forKey:@"self.authUserId"];
  [coder encodeObject:self.anonUserAcquisitionDate forKey:@"self.anonUserAcquisitionDate"];
  [coder encodeObject:self.authUserAcquisitionDate forKey:@"self.authUserAcquisitionDate"];
}

@end
