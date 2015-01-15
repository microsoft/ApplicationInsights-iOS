#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type StackFrame.
@interface MSAIStackFrame : MSAIObject

@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *assembly;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSNumber *line;


@end
