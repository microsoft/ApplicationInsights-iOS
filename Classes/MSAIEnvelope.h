#import "MSAIBase.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIEnvelope : MSAIObject <NSCoding>

@property (nonatomic, copy) NSNumber *version;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, strong) NSNumber *sampleRate;
@property (nonatomic, copy) NSString *seq;
@property (nonatomic, copy) NSString *iKey;
@property (nonatomic, strong) NSNumber *flags;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *os;
@property (nonatomic, copy) NSString *osVer;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appVer;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, strong) MSAIOrderedDictionary *tags;
@property (nonatomic, strong) MSAIBase *data;


@end
