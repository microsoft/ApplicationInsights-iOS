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

@implementation MSAIChannel

- (instancetype)initWithAppClient:(MSAIAppClient *) appClient telemetryContext:(MSAITelemetryContext *)telemetryContext {
  
  if ((self = [self init])) {
    _telemetryContext = telemetryContext;
    _sender = [MSAISender sharedSender];
    [_sender configureWithAppClient:appClient endpointPath:[_telemetryContext endpointPath]];
  }
  return self;
}

- (void)sendDataItem:(MSAITelemetryData *)dataItem {
  [dataItem setVersion:@(2)];
  
  MSAIData *data = [MSAIData new];
  [data setBaseData:dataItem];
  [data setBaseType:[dataItem dataTypeName]];
  
  MSAIEnvelope *envelope = [MSAIEnvelope new];
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
  [_sender enqueueDataDict:[envelope serializeToDictionary]];
}

- (NSString *)dateStringForDate:(NSDate *)date {
  NSDateFormatter *dateFormatter = [NSDateFormatter new];
  dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
  NSString *dateString = [dateFormatter stringFromDate:date];
  return dateString;
}

@end
