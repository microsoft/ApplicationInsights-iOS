#import "MSAIDomain.h"
#import "MSAISessionState.h"

@interface MSAISessionStateData : MSAIDomain <NSCoding>

@property (nonatomic, copy, readonly) NSString *envelopeTypeName;
@property (nonatomic, copy, readonly) NSString *dataTypeName;
@property (nonatomic, assign) MSAISessionState state;

@end
