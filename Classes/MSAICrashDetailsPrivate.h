#import "ApplicationInsights.h"

NS_ASSUME_NONNULL_BEGIN
extern NSString *const __unused kMSAICrashKillSignal;

@interface MSAICrashDetails () {
  
}

- (instancetype)initWithIncidentIdentifier:(NSString *)incidentIdentifier
                               reporterKey:(NSString *)reporterKey
                                    signal:(NSString *)signal
                             exceptionName:(NSString *)exceptionName
                           exceptionReason:(NSString *)exceptionReason
                              appStartTime:(NSDate *)appStartTime
                                 crashTime:(NSDate *)crashTime
                                 osVersion:(NSString *)osVersion
                                   osBuild:(NSString *)osBuild
                                  appBuild:(NSString *)appBuild;

@end
NS_ASSUME_NONNULL_END
