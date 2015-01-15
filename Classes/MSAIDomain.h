#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type Domain.
@interface MSAIDomain : MSAIObject

@property (nonatomic, strong, readonly)NSString *envelopeTypeName;
@property (nonatomic, strong, readonly)NSString *dataTypeName;

@end
