#import "MSAIContext.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSAIContext()

@property (nonatomic, strong, readonly) NSString *instrumentationKey;
@property (nonatomic, strong, readonly) NSString *osVersion;
@property (nonatomic, strong, readonly) NSString *osName;
@property (nonatomic, strong, readonly) NSString *deviceType;
@property (nonatomic, strong, readonly) NSString *deviceModel;
@property (nonatomic, strong, readonly) NSString *appVersion;

- (instancetype)initWithInstrumentationKey:(NSString *)instrumentationKey;

@end
NS_ASSUME_NONNULL_END
