#import "MSAIDomain.h"

@interface MSAIRequestData : MSAIDomain <NSCoding>

@property(nonatomic, copy, readonly)NSString *envelopeTypeName;
@property(nonatomic, copy, readonly)NSString *dataTypeName;
@property (nonatomic, strong) NSString *requestDataId;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *responseCode;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, strong) NSString *httpMethod;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) MSAIOrderedDictionary *measurements;

@end
