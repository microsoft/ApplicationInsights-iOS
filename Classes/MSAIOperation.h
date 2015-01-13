#import <Foundation/Foundation.h>
#import "MSAIDataPointType.h"
#import "MSAIDependencyKind.h"
#import "MSAIDependencySourceType.h"
#import "MSAISeverityLevel.h"
#import "MSAITelemetryData.h"

///Data contract class for type Operation.
@interface MSAIOperation : NSObject

@property (nonatomic, strong) NSString *operationId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *parentId;
@property (nonatomic, strong) NSString *rootId;

/// Serializes the object to a string in json format.
- (NSString *)serialize;

@end
