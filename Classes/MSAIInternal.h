#import <Foundation/Foundation.h>
#import "MSAIDataPointType.h"
#import "MSAIDependencyKind.h"
#import "MSAIDependencySourceType.h"
#import "MSAISeverityLevel.h"
#import "MSAITelemetryData.h"

///Data contract class for type Internal.
@interface MSAIInternal : NSObject

@property (nonatomic, strong) NSString *sdkVersion;
@property (nonatomic, strong) NSString *agentVersion;

/// Serializes the object to a string in json format.
- (NSString *)serialize;

@end
