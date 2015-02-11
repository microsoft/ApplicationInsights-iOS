#import "MSAIEnvelopeManager.h"
#import "MSAIEnvelopeManagerPrivate.h"
#import "MSAIEnvelope.h"
#import "MSAIData.h"
#import "MSAIDevice.h"
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAIHelper.h"
#import "MSAICrashDataProvider.h"

@implementation MSAIEnvelopeManager

- (void)configureWithTelemetryContext:(MSAITelemetryContext *)telemetryContext{

  @synchronized(self) {
    _telemetryContext = telemetryContext;
  }
}

+ (id)sharedManager {
  static MSAIEnvelopeManager *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [self new];
  });
  return sharedManager;
}

- (MSAIEnvelope *)envelope{
  
  MSAIEnvelope *envelope = [MSAIEnvelope new];
  envelope.appId = msai_mainBundleIdentifier();
  envelope.appVer = _telemetryContext.application.version;
  envelope.Time = [self dateStringForDate:[NSDate date]];
  envelope.iKey = _telemetryContext.instrumentationKey;
  
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

- (MSAIEnvelope *)envelopeForTelemetryData:(MSAITelemetryData *)telemetryData{
  [telemetryData setVersion:@(2)];
  
  MSAIData *data = [MSAIData new];
  data.baseData = telemetryData;
  data.baseType = telemetryData.dataTypeName;
  
  MSAIEnvelope *envelope = [self envelope];
  envelope.data = data;
  envelope.name = telemetryData.envelopeTypeName;
  
  return envelope;
}

- (MSAIEnvelope *)envelopeForCrashReport:(MSAIPLCrashReport *)report{
  return [self envelopeForCrashReport:report exception:nil];
}

- (MSAIEnvelope *)envelopeForCrashReport:(MSAIPLCrashReport *)report exception:(NSException *)exception{
  return [MSAICrashDataProvider crashDataForCrashReport:report handledException:exception];
}

- (NSString *)dateStringForDate:(NSDate *)date {
  NSDateFormatter *dateFormatter = [NSDateFormatter new];
  dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
  NSString *dateString = [dateFormatter stringFromDate:date];
  return dateString;
}

- (void)createNewSession{
  @synchronized(self) {
    [_telemetryContext createNewSession];
  }
}

@end
