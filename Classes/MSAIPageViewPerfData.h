#import "MSAIPageViewData.h"

@interface MSAIPageViewPerfData : MSAIPageViewData <NSCoding>

@property(nonatomic, copy, readonly)NSString *envelopeTypeName;
@property(nonatomic, copy, readonly)NSString *dataTypeName;
@property (nonatomic, copy) NSString *perfTotal;
@property (nonatomic, copy) NSString *networkConnect;
@property (nonatomic, copy) NSString *sentRequest;
@property (nonatomic, copy) NSString *receivedResponse;
@property (nonatomic, copy) NSString *domProcessing;

@end
