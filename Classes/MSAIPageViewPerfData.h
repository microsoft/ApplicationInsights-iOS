#import <Foundation/Foundation.h>
#import "MSAIDataPointType.h"
#import "MSAIDependencyKind.h"
#import "MSAIDependencySourceType.h"
#import "MSAISeverityLevel.h"
#import "MSAITelemetryData.h"

///Data contract class for type PageViewPerfData.
@interface MSAIPageViewPerfData : MSAITelemetryData

/// Needed to properly construct the JSON envelope.
@property (readonly, copy) NSString *envelopeTypeName;

/// Needed to properly construct the JSON envelope.
@property (readonly, copy) NSString *dataTypeName;
@property (nonatomic, strong) NSString *perfTotal;
@property (nonatomic, strong) NSString *networkConnect;
@property (nonatomic, strong) NSString *sentRequest;
@property (nonatomic, strong) NSString *receivedResponse;
@property (nonatomic, strong) NSString *domProcessing;

/// Serializes the object to a string in json format.
- (NSString *)serialize;

@end
