#import "MSAIObject.h"

@interface MSAICrashDataThread : MSAIObject <NSCoding>

@property (nonatomic, copy) NSNumber *crashDataThreadId;
@property (nonatomic, strong) NSMutableArray *frames;

@end
