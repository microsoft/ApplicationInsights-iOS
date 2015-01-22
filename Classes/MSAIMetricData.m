#import "MSAIMetricData.h"
/// Data contract class for type MetricData.
@implementation MSAIMetricData
@synthesize envelopeTypeName = _envelopeTypeName;
@synthesize dataTypeName = _dataTypeName;

/// Initializes a new instance of the class.
- (instancetype)init {
    if (self = [super init]) {
        _envelopeTypeName = @"Microsoft.ApplicationInsights.Metric";
        _dataTypeName = @"MetricData";
        self.version = [NSNumber numberWithInt:2];
        self.metrics = [NSMutableArray new];
        self.properties = [MSAIOrderedDictionary new];
    }
    return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
    MSAIOrderedDictionary *dict = [super serializeToDictionary];
    if (self.metrics != nil) {
        NSMutableArray *metricsArray = [NSMutableArray array];
        for (MSAIDataPoint *metricsElement in self.metrics) {
            [metricsArray addObject:[metricsElement serializeToDictionary]];
        }
        [dict setObject:metricsArray forKey:@"metrics"];
    }
    [dict setObject:self.properties forKey:@"properties"];
    return dict;
}

@end
