#import "MSAIBase.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type Envelope.
@interface MSAIEnvelope : MSAIObject

@property (nonatomic, strong) NSNumber *version;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSNumber *sampleRate;
@property (nonatomic, strong) NSString *seq;
@property (nonatomic, strong) NSString *iKey;
@property (nonatomic, strong) NSNumber *flags;
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *os;
@property (nonatomic, strong) NSString *osVer;
@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *appVer;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSMutableDictionary *tags;
@property (nonatomic, strong) MSAIBase *data;


@end
