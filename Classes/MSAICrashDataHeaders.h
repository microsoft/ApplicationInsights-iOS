#import "MSAIObject.h"
#import "MSAITelemetryData.h"
#import "MSAIDomain.h"

@interface MSAICrashDataHeaders : MSAIObject <NSCoding>

@property (nonatomic, copy) NSString *crashDataHeadersId;
@property (nonatomic, copy) NSString *process;
@property (nonatomic, strong) NSNumber *processId;
@property (nonatomic, copy) NSString *parentProcess;
@property (nonatomic, strong) NSNumber *parentProcessId;
@property (nonatomic, strong) NSNumber *crashThread;
@property (nonatomic, copy) NSString *applicationPath;
@property (nonatomic, copy) NSString *applicationIdentifier;
@property (nonatomic, copy) NSString *applicationBuild;
@property (nonatomic, copy) NSString *exceptionType;
@property (nonatomic, copy) NSString *exceptionCode;
@property (nonatomic, copy) NSString *exceptionAddress;
@property (nonatomic, copy) NSString *exceptionReason;

@end
