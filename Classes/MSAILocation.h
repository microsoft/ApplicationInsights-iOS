#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAILocation : MSAIObject <NSCoding>

@property (nonatomic, strong) NSString *ip;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;


@end
