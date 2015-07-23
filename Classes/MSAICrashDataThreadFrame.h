#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAICrashDataThreadFrame : MSAIObject <NSCoding>

@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, strong) NSDictionary *registers;

@end
