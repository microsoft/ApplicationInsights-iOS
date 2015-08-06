#import "MSAIObject.h"

@interface MSAIStackFrame : MSAIObject <NSCoding>

@property (nonatomic, copy) NSNumber *level;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *assembly;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSNumber *line;

@end
