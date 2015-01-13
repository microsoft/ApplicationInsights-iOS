#import <Foundation/Foundation.h>
#import "MSAIDataPointType.h"
#import "MSAIDependencyKind.h"
#import "MSAIDependencySourceType.h"
#import "MSAISeverityLevel.h"
#import "MSAITelemetryData.h"

///Data contract class for type StackFrame.
@interface MSAIStackFrame : NSObject

@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *assembly;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSNumber *line;

/// Serializes the object to a string in json format.
- (NSString *)serialize;

@end
