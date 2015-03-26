#import "MSAIContext.h"
#import "MSAIContextPrivate.h"
#import "MSAIHelper.h"

@implementation MSAIContext

@synthesize osVersion = _osVersion;
@synthesize osName = _osName;
@synthesize instrumentationKey = _instrumentationKey;
@synthesize deviceModel = _deviceModel;
@synthesize deviceType = _deviceType;
@synthesize appVersion = _appVersion;

- (instancetype)initWithInstrumentationKey:(NSString *)instrumentationKey {
  
  if ((self = [self init])) {
    _instrumentationKey = instrumentationKey;
    _deviceModel = msai_devicePlatform();
    _deviceType = msai_deviceType();
    _osName = msai_osName();
    _osVersion = msai_osVersionBuild();
    _appVersion = msai_appVersion();
  }
  return self;
}
@end
