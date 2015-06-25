#import "MSAIObject.h"

@interface MSAIInternal : MSAIObject <NSCoding>

@property (nonatomic, strong) NSString *sdkVersion;
@property (nonatomic, strong) NSString *agentVersion;

@end
