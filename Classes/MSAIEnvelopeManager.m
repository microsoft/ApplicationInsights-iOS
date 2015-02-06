#import "MSAIEnvelopeManager.h"
#import "MSAIEnvelopeManagerPrivate.h"
#import "MSAIEnvelope.h"
#import "MSAIData.h"
#import "MSAIDevice.h"
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAIHelper.h"

@implementation MSAIEnvelopeManager

- (void)configureWithTelemetryContext:(MSAITelemetryContext *)telemetryContext{

  @synchronized(self) {
    _telemetryContext = telemetryContext;
  }
}

+ (id)sharedChannel {
  static MSAIEnvelopeManager *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [self new];
  });
  return sharedManager;
}

- (MSAIEnvelope *)envelopeForTelemetryData:(MSAITelemetryData *)telemetryData{
  [telemetryData setVersion:@(2)];
  
  MSAIData *data = [MSAIData new];
  data.baseData = telemetryData;
  data.baseType = telemetryData.dataTypeName;
  
  MSAIEnvelope *envelope = [MSAIEnvelope new];
  envelope.appId = msai_mainBundleIdentifier();
  envelope.appVer = _telemetryContext.application.version;
  envelope.Time = [self dateStringForDate:[NSDate date]];
  envelope.iKey = _telemetryContext.instrumentationKey;
  envelope.data = data;
  envelope.name = telemetryData.envelopeTypeName;
  
  MSAIDevice *deviceContext = _telemetryContext.device;
  if (deviceContext.deviceId) {
    envelope.deviceId = deviceContext.deviceId;
  }
  if (deviceContext.os) {
    envelope.os = deviceContext.os;
  }
  if (deviceContext.osVersion) {
    envelope.osVer = deviceContext.osVersion;
  }
  
  envelope.tags = _telemetryContext.contextDictionary;
  return envelope;
}

- (NSString *)dateStringForDate:(NSDate *)date {
  NSDateFormatter *dateFormatter = [NSDateFormatter new];
  dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
  NSString *dateString = [dateFormatter stringFromDate:date];
  return dateString;
}

@end
