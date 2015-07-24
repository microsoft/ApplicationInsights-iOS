#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIStackFrame : MSAIObject <NSCoding>

@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *assembly;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, strong) NSNumber *line;

@end
