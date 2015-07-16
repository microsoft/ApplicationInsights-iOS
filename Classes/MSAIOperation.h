#import "MSAIObject.h"

@interface MSAIOperation : MSAIObject <NSCoding>

@property (nonatomic, strong) NSString *operationId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *parentId;
@property (nonatomic, strong) NSString *rootId;
@property (nonatomic, copy) NSString *syntheticSource;

@end
