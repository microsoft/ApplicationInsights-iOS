#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIInternal : MSAIObject <NSCoding>

@property (nonatomic, copy) NSString *sdkVersion;
@property (nonatomic, copy) NSString *agentVersion;
@property (nonatomic, copy) NSString *dataCollectorReceivedTime;
@property (nonatomic, copy) NSString *profileId;
@property (nonatomic, copy) NSString *profileClassId;
@property (nonatomic, copy) NSString *accountId;
@property (nonatomic, copy) NSString *applicationName;
@property (nonatomic, copy) NSString *instrumentationKey;
@property (nonatomic, copy) NSString *telemetryItemId;
@property (nonatomic, copy) NSString *applicationType;
@property (nonatomic, copy) NSString *requestSource;
@property (nonatomic, copy) NSString *flowType;
@property (nonatomic, copy) NSString *isAudit;
@property (nonatomic, copy) NSString *trackingSourceId;
@property (nonatomic, copy) NSString *trackingType;

@end
