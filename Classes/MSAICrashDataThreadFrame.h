#import "MSAIObject.h"

@interface MSAICrashDataThreadFrame : MSAIObject <NSCoding>

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *symbol;
@property (nonatomic, strong) NSMutableDictionary *registers;

@end
