#import "MSAISessionState.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAISessionStateData : MSAIDomain <NSCoding>

@property (nonatomic, assign) MSAISessionState state;

@end
