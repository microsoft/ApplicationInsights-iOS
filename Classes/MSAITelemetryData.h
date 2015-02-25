#import "MSAIObject.h"

///Data contract class for type MSAITelemetryData.
@interface MSAITelemetryData : MSAIObject <NSCoding>

@property (nonatomic, readonly, copy) NSString *envelopeTypeName;
@property (nonatomic, readonly, copy) NSString *dataTypeName;

@property (nonatomic, strong) NSNumber *version;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDictionary *properties;

@end
