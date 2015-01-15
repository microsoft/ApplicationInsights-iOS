#import "MSAIDomain.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type Data.
@interface MSAIData : MSAITelemetryData

@property (nonatomic, strong) MSAITelemetryData *baseData;


@end
