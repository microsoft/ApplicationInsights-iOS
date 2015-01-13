#import <Foundation/Foundation.h>
#import "MSAIDomain.h"
#import "MSAIDataPointType.h"
#import "MSAIDependencyKind.h"
#import "MSAIDependencySourceType.h"
#import "MSAISeverityLevel.h"
#import "MSAITelemetryData.h"

///Data contract class for type Data.
@interface MSAIData : MSAITelemetryData

@property (nonatomic, strong) MSAITelemetryData *baseData;

/// Serializes the object to a string in json format.
- (NSString *)serialize;

@end
