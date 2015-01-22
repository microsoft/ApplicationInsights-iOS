#import "MSAIExceptionDetails.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIExceptionData : MSAIDomain

@property (nonatomic, strong, readonly) NSString *envelopeTypeName;
@property (nonatomic, strong, readonly) NSString *dataTypeName;
@property (nonatomic, strong) NSString *handledAt;
@property (nonatomic, strong) NSMutableArray *exceptions;
@property (nonatomic, assign) MSAISeverityLevel severityLevel;
@property (nonatomic, strong) MSAIOrderedDictionary *measurements;


@end
