#import "MSAIDataPoint.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIMetricData : MSAIDomain <NSCoding>

@property (nonatomic, strong) NSMutableArray *metrics;

@end
