#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type EventData.
@interface MSAIEventData : MSAITelemetryData

@property (nonatomic, strong) NSDictionary *measurements;


@end
