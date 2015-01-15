#import "MSAIObject.h"
#import "MSAITelemetryData.h"

///Data contract class for type RequestData.
@interface MSAIRequestData : MSAITelemetryData

@property (nonatomic, strong) NSString *requestDataId;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *responseCode;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, strong) NSString *httpMethod;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSMutableDictionary *measurements;


@end
