#import "MSAIObject.h"

@interface MSAIApplication : MSAIObject <NSCoding>

@property (nonatomic, strong) NSString *version;

- (instancetype)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;


@end
