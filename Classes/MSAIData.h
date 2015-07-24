#import "MSAIBase.h"
#import "MSAIObject.h"
@class MSAITelemetryData;
#import "MSAIDomain.h"

@interface MSAIData : MSAIBase <NSCoding>

@property (nonatomic, strong) MSAITelemetryData *baseData;

- (instancetype)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

@end
