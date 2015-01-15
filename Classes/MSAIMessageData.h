#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type MessageData.
@interface MSAIMessageData : MSAITelemetryData

@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) MSAISeverityLevel severityLevel;


@end
