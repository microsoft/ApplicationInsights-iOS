#import "MSAIExceptionDetails.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type ExceptionData.
@interface MSAIExceptionData : MSAITelemetryData

@property (nonatomic, strong) NSString *handledAt;
@property (nonatomic, strong) NSMutableArray *exceptions;
@property (nonatomic, assign) MSAISeverityLevel severityLevel;
@property (nonatomic, strong) NSMutableDictionary *measurements;


@end
