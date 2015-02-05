#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIMessageData : MSAIDomain <NSCoding>

@property(nonatomic, copy, readonly)NSString *envelopeTypeName;
@property(nonatomic, copy, readonly)NSString *dataTypeName;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) MSAISeverityLevel severityLevel;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;


@end
