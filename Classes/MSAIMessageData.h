#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIMessageData : MSAIDomain

@property(nonatomic, strong, readonly)NSString *envelopeTypeName;
@property(nonatomic, strong, readonly)NSString *dataTypeName;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) MSAISeverityLevel severityLevel;


@end
