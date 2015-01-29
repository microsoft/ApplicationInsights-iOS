#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIInternal : MSAIObject

@property (nonatomic, strong) NSString *sdkVersion;
@property (nonatomic, strong) NSString *agentVersion;


@end
