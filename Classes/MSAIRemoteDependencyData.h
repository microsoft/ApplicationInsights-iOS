#import "MSAIDomain.h"
#import "MSAIDataPointType.h"
#import "MSAIDependencyKind.h"
#import "MSAIDependencySourceType.h"

@interface MSAIRemoteDependencyData : MSAIDomain <NSCoding>

@property (nonatomic, copy, readonly) NSString *envelopeTypeName;
@property (nonatomic, copy, readonly) NSString *dataTypeName;
@property (nonatomic, assign) MSAIDataPointType kind;
@property (nonatomic, copy) NSNumber *value;
@property (nonatomic, copy) NSNumber *count;
@property (nonatomic, copy) NSNumber *min;
@property (nonatomic, copy) NSNumber *max;
@property (nonatomic, copy) NSNumber *stdDev;
@property (nonatomic, assign) MSAIDependencyKind dependencyKind;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, assign) BOOL async;
@property (nonatomic, assign) MSAIDependencySourceType dependencySource;
@property (nonatomic, copy) NSString *commandName;
@property (nonatomic, copy) NSString *dependencyTypeName;

@end
