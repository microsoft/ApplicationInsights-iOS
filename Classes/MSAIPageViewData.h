#import "MSAIEventData.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIPageViewData : MSAIEventData <NSCoding>

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *referrer;
@property (nonatomic, copy) NSString *referrerData;

@end
