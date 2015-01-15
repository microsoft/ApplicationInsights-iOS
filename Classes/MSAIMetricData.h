#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type MetricData.
@interface MSAIMetricData : MSAITelemetryData

@property (nonatomic, strong) NSMutableArray *metrics;


@end
