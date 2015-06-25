#import "MSAIObject.h"

@interface MSAISession : MSAIObject <NSCoding>

@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, strong) NSString *isFirst;
@property (nonatomic, strong) NSString *isNew;

@end
