#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIApplication : MSAIObject <NSCoding>

@property (nonatomic, strong) NSString *version;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;


@end
