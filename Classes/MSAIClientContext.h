#import <Foundation/Foundation.h>

@interface MSAIClientContext : NSObject

/**
 *  The path to the telemetry endpoint.
 */
@property(nonatomic, strong) NSString *endpointPath;

/**
 *  The instrumentation key of the app.
 */
@property(nonatomic, strong) NSString *instrumentationKey;

/**
 *  Initialize the client context object.
 *
 *  @param instrumentationKey  the instrumentation key of the app.
 *  @param endpointPath        the path to the telemetry endpoint.
 *
 *  @return an instance of the client context.
 */
- (instancetype)initWithInstrumentationKey:(NSString *)instrumentationKey endpointPath:(NSString *)endpointPath;

@end
