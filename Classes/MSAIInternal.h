#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type Internal.
@interface MSAIInternal : MSAIObject

@property (nonatomic, strong) NSString *sdkVersion;
@property (nonatomic, strong) NSString *agentVersion;


@end
