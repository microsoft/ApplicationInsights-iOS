#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type PageViewPerfData.
@interface MSAIPageViewPerfData : MSAITelemetryData

@property (nonatomic, strong) NSString *perfTotal;
@property (nonatomic, strong) NSString *networkConnect;
@property (nonatomic, strong) NSString *sentRequest;
@property (nonatomic, strong) NSString *receivedResponse;
@property (nonatomic, strong) NSString *domProcessing;


@end
