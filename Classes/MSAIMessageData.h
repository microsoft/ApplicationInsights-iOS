#import "MSAIDomain.h"
#import "MSAIEnums.h"

@interface MSAIMessageData : MSAIDomain <NSCoding>

@property(nonatomic, copy, readonly)NSString *envelopeTypeName;
@property(nonatomic, copy, readonly)NSString *dataTypeName;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) MSAISeverityLevel severityLevel;

@end
