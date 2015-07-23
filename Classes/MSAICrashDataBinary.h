#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAICrashDataBinary : MSAIObject <NSCoding>

@property (nonatomic, copy) NSString *startAddress;
@property (nonatomic, copy) NSString *endAddress;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *cpuType;
@property (nonatomic, strong) NSNumber *cpuSubType;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *path;

@end
