#import <Foundation/Foundation.h>
#import "MSAIDataPointType.h"
#import "MSAIDependencyKind.h"
#import "MSAIDependencySourceType.h"
#import "MSAISeverityLevel.h"
#import "MSAITelemetryData.h"

///Data contract class for type Base.
@interface MSAIBase : NSObject

@property (nonatomic, strong) NSString *baseType;

/// Serializes the object to a string in json format.
- (NSString *)serialize;

@end
