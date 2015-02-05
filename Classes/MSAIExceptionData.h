#import "MSAIExceptionDetails.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIExceptionData : MSAIDomain <NSCoding>

@property (nonatomic, copy, readonly) NSString *envelopeTypeName;
@property (nonatomic, copy, readonly) NSString *dataTypeName;
@property (nonatomic, strong) NSString *handledAt;
@property (nonatomic, strong) NSMutableArray *exceptions;
@property (nonatomic, assign) MSAISeverityLevel severityLevel;
@property (nonatomic, strong) MSAIOrderedDictionary *measurements;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;


@end
