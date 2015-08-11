#import "MSAIObject.h"

@interface MSAICrashDataBinary : MSAIObject <NSCoding>

@property (nonatomic, copy) NSString *startAddress;
@property (nonatomic, copy) NSString *endAddress;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *cpuType;
@property (nonatomic, copy) NSNumber *cpuSubType;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *path;

@end
