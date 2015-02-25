#import "MSAIBase.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIData : MSAIBase <NSCoding>

@property (nonatomic, strong) MSAITelemetryData *baseData;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;


@end
