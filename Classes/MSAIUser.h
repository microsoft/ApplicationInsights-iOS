#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIUser : MSAIObject <NSCoding>

@property (nonatomic, strong) NSString *accountAcquisitionDate;
@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, strong) NSString *userAgent;
@property (nonatomic, strong) NSString *userId;

@end
