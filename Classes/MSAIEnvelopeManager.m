#import "MSAIEnvelopeManager.h"
#import "MSAIEnvelopeManagerPrivate.h"
#import "MSAIEnvelope.h"
#import "MSAIData.h"
#import "MSAIDevice.h"
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAIHelper.h"
#import "MSAICrashDataProvider.h"
#import "MSAIHelper.h"

static NSInteger const schemaVersion = 2;

@implementation MSAIEnvelopeManager

#pragma mark - Initialize and configure singleton instance

- (void)configureWithTelemetryContext:(MSAITelemetryContext *)telemetryContext {

  @synchronized(self) {
    _telemetryContext = telemetryContext;
  }
}

+ (instancetype)sharedManager {
  static MSAIEnvelopeManager *sharedManager = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [self new];
  });
  return sharedManager;
}

#pragma mark - Create envelope objects

- (MSAIEnvelope *)envelope {
  MSAIEnvelope *envelope = [MSAIEnvelope new];
  envelope.appId = msai_mainBundleIdentifier();
  envelope.appVer = _telemetryContext.appVersion;
  envelope.time = msai_utcDateString([NSDate date]);
  envelope.iKey = _telemetryContext.instrumentationKey;
  
  if (_telemetryContext.deviceId) {
    envelope.deviceId = _telemetryContext.deviceId;
  }
  if (_telemetryContext.osName) {
    envelope.os = _telemetryContext.osName;
  }
  if (_telemetryContext.osVersion) {
    envelope.osVer = _telemetryContext.osVersion;
  }
  
  envelope.tags = _telemetryContext.contextDictionary;
  return envelope;
}

- (MSAIEnvelope *)envelopeForTelemetryData:(MSAITelemetryData *)telemetryData {
  telemetryData.version = @(schemaVersion);
  
  MSAIData *data = [MSAIData new];
  data.baseData = telemetryData;
  data.baseType = telemetryData.dataTypeName;
  
  MSAIEnvelope *envelope = [self envelope];
  envelope.data = data;
  envelope.name = telemetryData.envelopeTypeName;
  
  return envelope;
}

- (MSAIEnvelope *)envelopeForCrashReport:(MSAIPLCrashReport *)report {
  return [self envelopeForCrashReport:report exception:nil];
}

- (MSAIEnvelope *)envelopeForCrashReport:(MSAIPLCrashReport *)report exception:(NSException *)exception {
  return [MSAICrashDataProvider crashDataForCrashReport:report handledException:exception];
}

@end
