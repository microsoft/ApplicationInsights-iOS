#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAICrashDataThreadFrame : MSAIObject

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *symbol;
@property (nonatomic, strong) NSMutableDictionary *registers;


@end
