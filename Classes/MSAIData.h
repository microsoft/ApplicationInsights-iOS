#import "MSAIDomain.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIBase.h"

///Data contract class for type Data.
@interface MSAIData : MSAIBase

@property (nonatomic, strong) MSAITelemetryData *baseData;


@end
