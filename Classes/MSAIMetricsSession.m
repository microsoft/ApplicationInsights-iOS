#import "MSAIMetricsSession.h"

/*
 * Request sent by the client to record a user session.
 */
@implementation MSAIMetricsSession

- (id)initWithInstallationUUID:(NSUUID *)installationUUID
                   deviceModel:(NSString *)deviceModel
               deviceOSVersion:(NSString *)deviceOSVersion
                  deviceLocale:(NSString *)deviceLocale
                   appLanguage:(NSString *)appLanguage
                      appBuild:(NSString *)appBuild
                    appVersion:(NSString *)appVersion
              sessionStartTime:(uint64_t)sessionStartTime
                sessionEndTime:(uint64_t)sessionEndTime
                  firstSession:(BOOL)firstSession
{
    if ((self = [super init]) == nil) {
        return nil;
    }

    _installationUUID = installationUUID;
    _deviceModel = deviceModel;
    _deviceOSVersion = deviceOSVersion;
    _deviceLocale = deviceLocale;
    _appLanguage = appLanguage;
    _appBuild = appBuild;
    _appVersion = appVersion;
    _sessionStartTime = sessionStartTime;
    _sessionEndTime = sessionEndTime;
    _firstSession = firstSession;

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:self.installationUUID forKey:@"identifier"];
  [encoder encodeObject:self.deviceModel forKey:@"model"];
  [encoder encodeObject:self.deviceOSVersion forKey:@"os"];
  [encoder encodeObject:self.deviceLocale forKey:@"locale"];
  [encoder encodeObject:self.appLanguage forKey:@"lang"];
  [encoder encodeObject:self.appBuild forKey:@"build"];
  [encoder encodeObject:self.appVersion forKey:@"version"];
  [encoder encodeInt64:self.sessionStartTime forKey:@"start"];
  [encoder encodeInt64:self.sessionEndTime forKey:@"end"];
  [encoder encodeBool:self.firstSession forKey:@"firstSession"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
  if ((self = [self init])) {
    _installationUUID = [decoder decodeObjectForKey:@"identifier"];
    _deviceModel = [decoder decodeObjectForKey:@"model"];
    _deviceOSVersion = [decoder decodeObjectForKey:@"os"];
    _deviceLocale = [decoder decodeObjectForKey:@"locale"];
    _appLanguage = [decoder decodeObjectForKey:@"lang"];
    _appBuild = [decoder decodeObjectForKey:@"build"];
    _appVersion = [decoder decodeObjectForKey:@"version"];
    _sessionStartTime = [decoder decodeInt64ForKey:@"start"];
    _sessionEndTime = [decoder decodeInt64ForKey:@"end"];
    _firstSession = [decoder decodeBoolForKey:@"firstSession"];
  }
  return self;
}

@end
