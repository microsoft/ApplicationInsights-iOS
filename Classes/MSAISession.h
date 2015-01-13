@import Foundation;
#import "MSAIDataPointType.h"
#import "MSAIDependencyKind.h"
#import "MSAIDependencySourceType.h"
#import "MSAISeverityLevel.h"
#import "MSAITelemetryData.h"

///Data contract class for type Session.
@interface MSAISession : NSObject

@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, strong) NSString *isFirst;
@property (nonatomic, strong) NSString *isNew;

/// Serializes the object to a string in json format.
- (NSString *)serialize;

@end
