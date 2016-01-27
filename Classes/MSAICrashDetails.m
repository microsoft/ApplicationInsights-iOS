#import "MSAICrashDetails.h"

#if MSAI_FEATURE_CRASH_REPORTER

#import "MSAICrashDetailsPrivate.h"

NSString *const kMSAICrashKillSignal = @"SIGKILL";

@implementation MSAICrashDetails

- (instancetype)initWithIncidentIdentifier:(NSString *)incidentIdentifier
                               reporterKey:(NSString *)reporterKey
                                    signal:(NSString *)signal
                             exceptionName:(NSString *)exceptionName
                           exceptionReason:(NSString *)exceptionReason
                              appStartTime:(NSDate *)appStartTime
                                 crashTime:(NSDate *)crashTime
                                 osVersion:(NSString *)osVersion
                                   osBuild:(NSString *)osBuild
                                  appBuild:(NSString *)appBuild
{
  if ((self = [super init])) {
    _incidentIdentifier = incidentIdentifier;
    _reporterKey = reporterKey;
    _signal = signal;
    _exceptionName = exceptionName;
    _exceptionReason = exceptionReason;
    _appStartTime = appStartTime;
    _crashTime = crashTime;
    _osVersion = osVersion;
    _osBuild = osBuild;
    _appBuild = appBuild;
  }
  return self;
}

- (BOOL)isAppKill {
  BOOL result = NO;
  
  if (_signal && [[_signal uppercaseString] isEqualToString:kMSAICrashKillSignal])
    result = YES;
  
  return result;
}

@end

#endif /* MSAI_FEATURE_CRASH_REPORTER */
