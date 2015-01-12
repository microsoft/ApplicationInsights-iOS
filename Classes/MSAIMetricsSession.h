#import <Foundation/Foundation.h>

@interface MSAIMetricsSession : NSObject

- (id)initWithInstallationUUID:(NSUUID *)installationUUID
                   deviceModel:(NSString *)deviceModel
               deviceOSVersion:(NSString *)deviceOSVersion
                  deviceLocale:(NSString *)deviceLocale
                   appLanguage:(NSString *)appLanguage
                      appBuild:(NSString *)appBuild
                    appVersion:(NSString *)appVersion
              sessionStartTime:(uint64_t)sessionStartTime
                sessionEndTime:(uint64_t)sessionEndTime
                  firstSession:(BOOL)firstSession;

/** The installation identifier (unique per app installation), expressed as a UUID. */
@property (nonatomic, strong, readonly) NSUUID *installationUUID;

/** The device model (e.g. "iPhone3,1"). */
@property (nonatomic, strong, readonly) NSString *deviceModel;

/** The device OS version (e.g. "7.0.1"). */
@property (nonatomic, strong, readonly) NSString *deviceOSVersion;

/** The device locale (ISO 639-1 [_ ISO 3166-1] convention, e.g. en, en_GB, en-GB_US). */
@property (nonatomic, strong, readonly) NSString *deviceLocale;

/** The application language (ISO 639-1 [- ISO 3166-1] convention, e.g. en, en-US). */
@property (nonatomic, strong, readonly) NSString *appLanguage;

/** The application build string. */
@property (nonatomic, strong, readonly) NSString *appBuild;

/** The application version string. */
@property (nonatomic, strong, readonly) NSString *appVersion;

/** The application binary UUID (used to identify when multiple builds use the same build and version strings). */
@property (nonatomic, strong, readonly) NSUUID *appBinaryUUID;

/** The session start time, in milliseconds since the UNIX epoch. */
@property (nonatomic, assign, readonly) uint64_t sessionStartTime;

/** The session end time, in milliseconds since the UNIX epoch. */
@property (nonatomic, assign, readonly) uint64_t sessionEndTime;

/** Whether this is the first session for the (appId, appVersion, installationUUID) combination. */
@property (nonatomic, assign, readonly) BOOL firstSession;

@end
