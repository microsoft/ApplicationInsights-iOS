#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIEventData : MSAIDomain <NSCoding>

@property (nonatomic, strong) NSDictionary *measurements;

@end
