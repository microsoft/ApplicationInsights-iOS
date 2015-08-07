#import "MSAIObject.h"

@interface MSAICrashDataHeaders : MSAIObject <NSCoding>

@property (nonatomic, copy) NSString *crashDataHeadersId;
@property (nonatomic, copy) NSString *process;
@property (nonatomic, copy) NSNumber *processId;
@property (nonatomic, copy) NSString *parentProcess;
@property (nonatomic, copy) NSNumber *parentProcessId;
@property (nonatomic, copy) NSNumber *crashThread;
@property (nonatomic, copy) NSString *applicationPath;
@property (nonatomic, copy) NSString *applicationIdentifier;
@property (nonatomic, copy) NSString *applicationBuild;
@property (nonatomic, copy) NSString *exceptionType;
@property (nonatomic, copy) NSString *exceptionCode;
@property (nonatomic, copy) NSString *exceptionAddress;
@property (nonatomic, copy) NSString *exceptionReason;

@end
