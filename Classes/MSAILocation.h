#import <Foundation/Foundation.h>
#import "MSAIDataPointType.h"
#import "MSAIDependencyKind.h"
#import "MSAIDependencySourceType.h"
#import "MSAISeverityLevel.h"
#import "MSAITelemetryData.h"

///Data contract class for type Location.
@interface MSAILocation : NSObject

@property (nonatomic, strong) NSString *ip;

/// Serializes the object to a string in json format.
- (NSString *)serialize;

@end
