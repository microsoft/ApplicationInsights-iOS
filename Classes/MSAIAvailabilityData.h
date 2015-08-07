#import "MSAITestResult.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAIAvailabilityData : MSAIDomain <NSCoding>

@property (nonatomic, copy) NSString *testRunId;
@property (nonatomic, copy) NSString *testTimeStamp;
@property (nonatomic, copy) NSString *testName;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, strong) MSAITestResult *result;
@property (nonatomic, copy) NSString *runLocation;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSNumber *dataSize;
@property (nonatomic, strong) NSDictionary *measurements;

@end
