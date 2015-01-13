@import Foundation;
#import "MSAIDataPointType.h"
#import "MSAIDependencyKind.h"
#import "MSAIDependencySourceType.h"
#import "MSAISeverityLevel.h"
#import "MSAITelemetryData.h"

///Data contract class for type RequestData.
@interface MSAIRequestData : MSAITelemetryData

/// Needed to properly construct the JSON envelope.
@property (readonly, copy) NSString *envelopeTypeName;

/// Needed to properly construct the JSON envelope.
@property (readonly, copy) NSString *dataTypeName;
@property (nonatomic, strong) NSNumber *version;
@property (nonatomic, strong) NSString *requestDataId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *responseCode;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, strong) NSString *httpMethod;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSMutableDictionary *properties;
@property (nonatomic, strong) NSMutableDictionary *measurements;

/// Serializes the object to a string in json format.
- (NSString *)serialize;

@end
