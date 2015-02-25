#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAICrashDataHeaders : MSAIObject <NSCoding>

@property (nonatomic, strong) NSString *crashDataHeadersId;
@property (nonatomic, strong) NSString *process;
@property (nonatomic, strong) NSNumber *processId;
@property (nonatomic, strong) NSString *parentProcess;
@property (nonatomic, strong) NSNumber *parentProcessId;
@property (nonatomic, strong) NSNumber *crashThread;
@property (nonatomic, strong) NSString *applicationPath;
@property (nonatomic, strong) NSString *applicationIdentifier;
@property (nonatomic, strong) NSString *applicationBuild;
@property (nonatomic, strong) NSString *exceptionType;
@property (nonatomic, strong) NSString *exceptionCode;
@property (nonatomic, strong) NSString *exceptionAddress;
@property (nonatomic, strong) NSString *exceptionReason;

@end
