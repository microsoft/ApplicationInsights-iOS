#import "MSAICrashDataHeaders.h"
#import "MSAICrashDataThread.h"
#import "MSAICrashDataBinary.h"
#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAICrashData : MSAIDomain <NSCoding>

@property (nonatomic, copy, readonly) NSString *envelopeTypeName;
@property (nonatomic, copy, readonly) NSString *dataTypeName;
@property (nonatomic, strong) MSAICrashDataHeaders *headers;
@property (nonatomic, strong) NSMutableArray *threads;
@property (nonatomic, strong) NSMutableArray *binaries;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;


@end
