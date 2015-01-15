#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type RemoteDependencyData.
@interface MSAIRemoteDependencyData : MSAITelemetryData

@property (nonatomic, assign) MSAIDataPointType kind;
@property (nonatomic, strong) NSNumber *value;
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSNumber *min;
@property (nonatomic, strong) NSNumber *max;
@property (nonatomic, strong) NSNumber *stdDev;
@property (nonatomic, assign) MSAIDependencyKind dependencyKind;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, assign) BOOL async;
@property (nonatomic, assign) MSAIDependencySourceType dependencySource;


@end
