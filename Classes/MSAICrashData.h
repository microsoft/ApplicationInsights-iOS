#import "MSAICrashDataHeaders.h"
#import "MSAICrashDataThread.h"
#import "MSAICrashDataBinary.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAICrashData : MSAIDomain <NSCoding>

//TODO What happened to envelopeTypeName and dataTypeName
@property (nonatomic, strong) MSAICrashDataHeaders *headers;
@property (nonatomic, strong) NSMutableArray *threads;
@property (nonatomic, strong) NSMutableArray *binaries;

- (instancetype)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

@end
