#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIStackFrame : MSAIObject <NSCoding>

@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *assembly;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSNumber *line;

@end
