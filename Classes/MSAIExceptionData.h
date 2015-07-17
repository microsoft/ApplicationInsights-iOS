#import "MSAIDomain.h"
#import "MSAIEnums.h"

@interface MSAIExceptionData : MSAIDomain <NSCoding>

@property (nonatomic, copy, readonly) NSString *envelopeTypeName;
@property (nonatomic, copy, readonly) NSString *dataTypeName;
@property (nonatomic, copy) NSString *handledAt;
@property (nonatomic, copy) NSString *problemId;
@property (nonatomic, copy) NSNumber *crashThreadId;
@property (nonatomic, strong) NSMutableArray *exceptions;
@property (nonatomic, assign) MSAISeverityLevel severityLevel;
@property (nonatomic, strong) MSAIOrderedDictionary *measurements;

- (instancetype)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

@end
