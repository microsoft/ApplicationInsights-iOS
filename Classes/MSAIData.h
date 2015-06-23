#import "MSAIBase.h"
@class MSAITelemetryData;

@interface MSAIData : MSAIBase <NSCoding>

@property (nonatomic, strong) MSAITelemetryData *baseData;

- (instancetype)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;


@end
