#import "MSAIEventData.h"

@interface MSAIPageViewData : MSAIEventData <NSCoding>

@property(nonatomic, copy, readonly)NSString *envelopeTypeName;
@property(nonatomic, copy, readonly)NSString *dataTypeName;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *referrer;
@property (nonatomic, copy) NSString *referrerData;

@end
