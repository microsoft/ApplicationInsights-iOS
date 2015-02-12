#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAICrashDataBinary : MSAIObject <NSCoding>

@property (nonatomic, strong) NSString *startAddress;
@property (nonatomic, strong) NSString *endAddress;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *cpuType;
@property (nonatomic, strong) NSNumber *cpuSubType;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *path;

@end
