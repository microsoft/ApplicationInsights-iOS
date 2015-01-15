#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type User.
@interface MSAIUser : MSAIObject

@property (nonatomic, strong) NSString *accountAcquisitionDate;
@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, strong) NSString *userAgent;
@property (nonatomic, strong) NSString *userId;


@end
