#import "MSAISeverityLevel.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIMessageData : MSAIDomain <NSCoding>

@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) MSAISeverityLevel severityLevel;

@end
