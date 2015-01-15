#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type ExceptionDetails.
@interface MSAIExceptionDetails : MSAIObject

@property (nonatomic, strong) NSNumber *exceptionDetailsId;
@property (nonatomic, strong) NSNumber *outerId;
@property (nonatomic, strong) NSString *typeName;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) BOOL hasFullStack;
@property (nonatomic, strong) NSString *stack;
@property (nonatomic, strong) NSMutableArray *parsedStack;


@end
