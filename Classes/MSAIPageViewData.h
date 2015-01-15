#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type PageViewData.
@interface MSAIPageViewData : MSAITelemetryData

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *duration;


@end
