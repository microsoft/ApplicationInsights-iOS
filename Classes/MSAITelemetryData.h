@import Foundation;
#import "MSAIDataPointType.h"
#import "MSAIDependencyKind.h"
#import "MSAIDependencySourceType.h"
#import "MSAISeverityLevel.h"

///Data contract class for type MSAITelemetryData.
@interface MSAITelemetryData : NSObject 

/// Initializes a new instance of the class.
- (instancetype)init;

/// Serializes the object to a string in json format.
- (NSString *)serialize;

@end
