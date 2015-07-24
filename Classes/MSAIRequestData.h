#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIRequestData : MSAIDomain <NSCoding>

@property (nonatomic, copy) NSString *requestDataId;
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *responseCode;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, copy) NSString *httpMethod;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) MSAIOrderedDictionary *measurements;

@end
