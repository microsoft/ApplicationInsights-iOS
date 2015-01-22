#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIEventData : MSAIDomain

@property (nonatomic, strong, readonly) NSString *envelopeTypeName;
@property (nonatomic, strong, readonly) NSString *dataTypeName;
@property (nonatomic, strong) NSDictionary *measurements;


@end
