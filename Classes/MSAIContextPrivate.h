#import "MSAIContext.h"

@interface MSAIContext()

@property (readonly) BOOL isAppStoreEnvironment;
@property (nonatomic, strong, readonly) NSString *instrumentationKey;
@property (nonatomic, strong, readonly) NSString *osVersion;
@property (nonatomic, strong, readonly) NSString *osName;
@property (nonatomic, strong, readonly) NSString *deviceType;
@property (nonatomic, strong, readonly) NSString *deviceModel;
@property (nonatomic, strong, readonly) NSString *appVersion;

- (instancetype)initWithInstrumentationKey:(NSString *)instrumentationKey isAppStoreEnvironment:(BOOL)isAppStoreEnvironment;

@end
