#import "MSAIEventData.h"

@interface MSAIPageViewData : MSAIEventData <NSCoding>

@property(nonatomic, copy, readonly)NSString *envelopeTypeName;
@property(nonatomic, copy, readonly)NSString *dataTypeName;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *duration;

@end
