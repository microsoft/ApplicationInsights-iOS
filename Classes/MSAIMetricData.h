#import "MSAIDataPoint.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIMetricData : MSAIDomain

@property(nonatomic, strong, readonly)NSString *envelopeTypeName;
@property(nonatomic, strong, readonly)NSString *dataTypeName;
@property (nonatomic, strong) NSMutableArray *metrics;


@end
