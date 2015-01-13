#import <Foundation/Foundation.h>

@interface MSAIClientConfig : NSObject

@property (nonatomic, strong) NSString *instrumentationKey;

- (instancetype)initWithInstrumentationKey:(NSString *)instrumentationKey;

@end
