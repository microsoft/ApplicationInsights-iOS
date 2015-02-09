#import "MSAIChannel.h"
#import "MSAIChannelPrivate.h"
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAIEnvelope.h"
#import "MSAIHTTPOperation.h"
#import "MSAIAppClient.h"
#import "AppInsightsPrivate.h"
#import "MSAIData.h"
#import "MSAISender.h"
#import "MSAISenderPrivate.h"
#import "MSAIHelper.h"

@implementation MSAIChannel

#pragma mark - Initialisation

- (instancetype)configureWithAppClient:(MSAIAppClient *) appClient telemetryContext:(MSAITelemetryContext *)telemetryContext {
  
    _telemetryContext = telemetryContext;
    _sender = [MSAISender sharedSender];
    [_sender configureWithAppClient:appClient endpointPath:[_telemetryContext endpointPath]];

  return self;
}

+ (id)sharedChannel {
  static MSAIChannel *sharedChannel = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedChannel = [self new];
  });
  return sharedChannel;
}

#pragma mark - Enqueue data

- (void)sendDataItem:(MSAITelemetryData *)dataItem {
  NSDictionary *dataDict = [self dictionaryFromDataItem:dataItem];
  [_sender enqueueDataDict:dataDict];
}

- (void)sendCrashItem:(MSAICrashData *)crashItem withCompletionBlock:(MSAINetworkCompletionBlock) completion{
  NSDictionary *crashDict = [self dictionaryFromDataItem:crashItem];
  [_sender enqueueCrashDict:crashDict withCompletionBlock:completion];
}

#pragma mark - Helper

- (NSDictionary *)dictionaryFromDataItem:(MSAITelemetryData *)dataItem{
  [dataItem setVersion:@(2)];
  
  MSAIData *data = [MSAIData new];
  [data setBaseData:dataItem];
  [data setBaseType:[dataItem dataTypeName]];
  
  MSAIEnvelope *envelope = [MSAIEnvelope new];
  envelope.appId = msai_mainBundleIdentifier();
  envelope.appVer = msai_appVersion();
  [envelope setTime:[self dateStringForDate:[NSDate date]]];
  [envelope setIKey:[_telemetryContext instrumentationKey]];
  [envelope setData:data];
  [envelope setName:[dataItem envelopeTypeName]];
  
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
  
  [envelope setTags:[_telemetryContext  contextDictionary]];
  return [envelope serializeToDictionary];
}

- (NSString *)dateStringForDate:(NSDate *)date {
  NSDateFormatter *dateFormatter = [NSDateFormatter new];
  dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
  NSString *dateString = [dateFormatter stringFromDate:date];
  return dateString;
}

@end
