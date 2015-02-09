#import "MSAICrashDataHeaders.h"
#import "MSAICrashDataThread.h"
#import "MSAICrashDataBinary.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAICrashData : MSAIDomain

@property(nonatomic, strong, readonly)NSString *envelopeTypeName;
@property(nonatomic, strong, readonly)NSString *dataTypeName;
@property (nonatomic, strong) MSAICrashDataHeaders *headers;
@property (nonatomic, strong) NSMutableArray *threads;
@property (nonatomic, strong) NSMutableArray *binaries;


@end
