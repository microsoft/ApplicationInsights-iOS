#import <Foundation/Foundation.h>

@interface MSAIClientContext : NSObject

@property(nonatomic, strong) NSString *endpointPath;
@property(nonatomic, strong) NSString *instrumentationKey;

- (instancetype)initWithInstrumentationKey:(NSString *)instrumentationKey endpointPath:(NSString *)endpointPath;

@end
