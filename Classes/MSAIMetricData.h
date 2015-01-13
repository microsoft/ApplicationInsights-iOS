#import <Foundation/Foundation.h>
#import "MSAIDataPointType.h"
#import "MSAIDependencyKind.h"
#import "MSAIDependencySourceType.h"
#import "MSAISeverityLevel.h"
#import "MSAITelemetryData.h"

///Data contract class for type MetricData.
@interface MSAIMetricData : MSAITelemetryData

/// Needed to properly construct the JSON envelope.
@property (readonly, copy) NSString *envelopeTypeName;

/// Needed to properly construct the JSON envelope.
@property (readonly, copy) NSString *dataTypeName;
@property (nonatomic, strong) NSNumber *version;
@property (nonatomic, strong) NSMutableArray *metrics;
@property (nonatomic, strong) NSMutableDictionary *properties;

/// Serializes the object to a string in json format.
- (NSString *)serialize;

@end
