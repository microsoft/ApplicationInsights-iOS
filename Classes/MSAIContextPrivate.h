#import "MSAIContext.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSAIContext()

@property (nonatomic, copy, readonly) NSString *instrumentationKey;
@property (nonatomic, copy, readonly) NSString *osVersion;
@property (nonatomic, copy, readonly) NSString *osName;
@property (nonatomic, copy, readonly) NSString *deviceType;
@property (nonatomic, copy, readonly) NSString *deviceModel;
@property (nonatomic, copy, readonly) NSString *appVersion;

- (instancetype)initWithInstrumentationKey:(NSString *)instrumentationKey;

@end
NS_ASSUME_NONNULL_END
