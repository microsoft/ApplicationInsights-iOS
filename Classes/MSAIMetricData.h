#import "MSAIDomain.h"

@interface MSAIMetricData : MSAIDomain <NSCoding>

@property(nonatomic, copy, readonly)NSString *envelopeTypeName;
@property(nonatomic, copy, readonly)NSString *dataTypeName;
@property (nonatomic, strong) NSMutableArray *metrics;

@end
