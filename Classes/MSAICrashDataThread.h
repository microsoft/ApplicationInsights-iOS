#import "MSAICrashDataThreadFrame.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAICrashDataThread : MSAIObject <NSCoding>

@property (nonatomic, strong) NSNumber *crashDataThreadId;
@property (nonatomic, strong) NSMutableArray *frames;

@end
