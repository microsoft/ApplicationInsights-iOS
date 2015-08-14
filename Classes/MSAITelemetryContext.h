#import <Foundation/Foundation.h>
#import "MSAINullability.h"

FOUNDATION_EXPORT NSString *const kMSAIApplicationWasLaunched;

NS_ASSUME_NONNULL_BEGIN
/**
 *  Context object which contains information about the device, user, session etc.
 */
@interface MSAITelemetryContext : NSObject

/**
 *  The instrumentation key of the app.
 */
@property(nonatomic, copy) NSString *instrumentationKey;

- (NSString *)screenResolution;

- (void)setScreenResolution:(NSString *)screenResolution;

- (NSString *)appVersion;

- (void)setAppVersion:(NSString *)appVersion;

- (NSString *)userId;

- (void)setUserId:(NSString *)userId;

- (NSString *)userAcquisitionDate;

- (void)setUserAcquisitionDate:(NSString *)userAcqusitionDate;

- (NSString *)accountId;

- (void)setAccountId:(NSString *)accountId;

- (NSString *)authenticatedUserId;

- (void)setAuthenticatedUserId:(NSString *)authenticatedUserId;

- (NSString *)authenticatedUserAcquisitionDate;

- (void)setAuthenticatedUserAcquisitionDate:(NSString *)authenticatedUserAcquisitionDate;

- (NSString *)anonymousUserAquisitionDate;

- (void)setAnonymousUserAquisitionDate:(NSString *)anonymousUserAquisitionDate;

- (NSString *)sdkVersion;

- (void)setSdkVersion:(NSString *)sdkVersion;

- (NSString *)sessionId;

- (void)setSessionId:(NSString *)sessionId;

- (NSString *)osVersion;

- (void)setOsVersion:(NSString *)osVersion;

- (NSString *)osName;

- (void)setOsName:(NSString *)osName;

- (NSString *)deviceModel;

- (void)setDeviceModel:(NSString *)deviceModel;

- (NSString *)deviceOemName;

- (void)setDeviceOemName:(NSString *)oemName;

- (NSString *)osLocale;

- (void)setOsLocale:(NSString *)osLocale;

- (NSString *)deviceId;

- (void)setDeviceId:(NSString *)deviceId;

- (NSString *)deviceType;

- (void)setDeviceType:(NSString *)deviceType;

- (NSString *)networkType;

- (void)setNetworkType:(NSString *)networkType;



@end
NS_ASSUME_NONNULL_END
