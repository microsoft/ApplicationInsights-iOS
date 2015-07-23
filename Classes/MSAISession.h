#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAISession : MSAIObject <NSCoding>

@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *isFirst;
@property (nonatomic, copy) NSString *isNew;

@end
