#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type Session.
@interface MSAISession : MSAIObject

@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, strong) NSString *isFirst;
@property (nonatomic, strong) NSString *isNew;


@end
