#import "MSAIObject.h"

@interface MSAIInternal : MSAIObject <NSCoding>

@property (nonatomic, copy) NSString *sdkVersion;
@property (nonatomic, copy) NSString *agentVersion;

@end
