#import "MSAIObject.h"
#import "MSAIDataPointType.h"

@interface MSAIDataPoint : MSAIObject <NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) MSAIDataPointType kind;
@property (nonatomic, copy) NSNumber *value;
@property (nonatomic, copy) NSNumber *count;
@property (nonatomic, copy) NSNumber *min;
@property (nonatomic, copy) NSNumber *max;
@property (nonatomic, copy) NSNumber *stdDev;

- (instancetype)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;


@end
