#import "MSAIPageViewData.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIPageViewPerfData : MSAIPageViewData <NSCoding>

@property(nonatomic, copy, readonly)NSString *envelopeTypeName;
@property(nonatomic, copy, readonly)NSString *dataTypeName;
@property (nonatomic, strong) NSString *perfTotal;
@property (nonatomic, strong) NSString *networkConnect;
@property (nonatomic, strong) NSString *sentRequest;
@property (nonatomic, strong) NSString *receivedResponse;
@property (nonatomic, strong) NSString *domProcessing;

@end
