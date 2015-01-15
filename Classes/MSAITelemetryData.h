#import "MSAIObject.h"

///Data contract class for type MSAITelemetryData.
@interface MSAITelemetryData : MSAIObject

/// Needed to properly construct the JSON envelope.
@property (readonly, copy) NSString *envelopeTypeName;

/// Needed to properly construct the JSON envelope.
@property (readonly, copy) NSString *dataTypeName;
@property (nonatomic, strong) NSNumber *version;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDictionary *properties;

@end
