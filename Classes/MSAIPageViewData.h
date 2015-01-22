#import "MSAIEventData.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIPageViewData : MSAIEventData

@property(nonatomic, strong, readonly)NSString *envelopeTypeName;
@property(nonatomic, strong, readonly)NSString *dataTypeName;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *duration;


@end
