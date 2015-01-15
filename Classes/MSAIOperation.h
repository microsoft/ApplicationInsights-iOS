#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type Operation.
@interface MSAIOperation : MSAIObject

@property (nonatomic, strong) NSString *operationId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *parentId;
@property (nonatomic, strong) NSString *rootId;


@end
