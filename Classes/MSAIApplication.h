#import "MSAIObject.h"

@interface MSAIApplication : MSAIObject <NSCoding>

@property (nonatomic, copy) NSString *version;

- (instancetype)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;


@end
