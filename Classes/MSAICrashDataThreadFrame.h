#import "MSAIObject.h"

@interface MSAICrashDataThreadFrame : MSAIObject <NSCoding>

@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, strong) NSMutableDictionary *registers;

@end
