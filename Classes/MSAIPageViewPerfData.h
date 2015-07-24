#import "MSAIPageViewData.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIPageViewPerfData : MSAIPageViewData <NSCoding>

@property (nonatomic, copy) NSString *perfTotal;
@property (nonatomic, copy) NSString *networkConnect;
@property (nonatomic, copy) NSString *sentRequest;
@property (nonatomic, copy) NSString *receivedResponse;
@property (nonatomic, copy) NSString *domProcessing;

@end
