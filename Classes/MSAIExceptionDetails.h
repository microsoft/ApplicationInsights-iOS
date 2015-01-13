#import <Foundation/Foundation.h>
#import "MSAIDataPointType.h"
#import "MSAIDependencyKind.h"
#import "MSAIDependencySourceType.h"
#import "MSAISeverityLevel.h"
#import "MSAITelemetryData.h"

///Data contract class for type ExceptionDetails.
@interface MSAIExceptionDetails : NSObject

@property (nonatomic, strong) NSNumber *exceptionDetailsId;
@property (nonatomic, strong) NSNumber *outerId;
@property (nonatomic, strong) NSString *typeName;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) BOOL hasFullStack;
@property (nonatomic, strong) NSString *stack;
@property (nonatomic, strong) NSMutableArray *parsedStack;

/// Serializes the object to a string in json format.
- (NSString *)serialize;

@end
