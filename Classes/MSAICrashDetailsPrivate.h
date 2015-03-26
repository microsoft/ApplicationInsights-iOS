#import <AppInsights/AppInsights.h>

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
