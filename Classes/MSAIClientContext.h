#import <Foundation/Foundation.h>
#import "MSAIApplication.h"
#import "MSAIDevice.h"
#import "MSAIOperation.h"
#import "MSAIInternal.h"
#import "MSAIUser.h"
#import "MSAISession.h"
#import "MSAILocation.h"

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
 *  The application context.
 */
@property(nonatomic, strong) MSAIApplication *application;

/**
 *  The device context.
 */
@property (nonatomic, strong)MSAIDevice *device;

/**
 *  The location context.
 */
@property (nonatomic, strong)MSAILocation *location;

/**
 *  The session context.
 */
@property (nonatomic, strong)MSAISession *session;

/**
 *  The user context.
 */
@property (nonatomic, strong)MSAIUser *user;

/**
 *  The internal context.
 */
@property (nonatomic, strong)MSAIInternal *internal;

/**
 *  The operation context.
 */
@property (nonatomic, strong)MSAIOperation *operation;


/**
 *  Initialize the client context object.
 *
 *  @param instrumentationKey  the instrumentation key of the app.
 *  @param endpointPath        the path to the telemetry endpoint.
 *
 *  @return an instance of the client context.
 */
- (instancetype)initWithInstrumentationKey:(NSString *)instrumentationKey endpointPath:(NSString *)endpointPath;

/**
 *  Returns context objects as dictionary.
 *
 *  @return a dictionary containing all context fields
 */
- (NSDictionary *)contextDictionary;

@end
