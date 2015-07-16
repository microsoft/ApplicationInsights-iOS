#import "MSAIObject.h"

@interface MSAIUser : MSAIObject <NSCoding>

@property (nonatomic, strong) NSString *accountAcquisitionDate;
@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, strong) NSString *userAgent;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, copy) NSString *storeRegion;

@end
