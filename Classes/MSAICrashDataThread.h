#import "MSAIObject.h"

@interface MSAICrashDataThread : MSAIObject <NSCoding>

@property (nonatomic, strong) NSNumber *crashDataThreadId;
@property (nonatomic, strong) NSMutableArray *frames;

@end
