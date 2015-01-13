#import <Foundation/Foundation.h>
#import "MSAIDataPointType.h"
#import "MSAIDependencyKind.h"
#import "MSAIDependencySourceType.h"
#import "MSAISeverityLevel.h"
#import "MSAITelemetryData.h"

///Data contract class for type Application.
@interface MSAIApplication : NSObject

@property (nonatomic, strong) NSString *version;

/// Serializes the object to a string in json format.
- (NSString *)serialize;

@end
