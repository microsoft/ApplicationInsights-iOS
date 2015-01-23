#import "AppInsights.h"

#if MSAI_FEATURE_METRICS

#import "AppInsightsPrivate.h"

#import "MSAIHelper.h"

#import "MSAIBaseManagerPrivate.h"
#import "MSAIMetricsManagerPrivate.h"
#import "MSAIMetricsSession.h"
#import "MSAIChannel.h"
#import "MSAIChannelPrivate.h"
#import "MSAITelemetryContext.h"
#import "MSAIContext.h"
#import "MSAIContextPrivate.h"

#import "MSAIEventData.h"
#import "MSAIMessageData.h"
#import "MSAIMetricData.h"
#import "MSAIDataPoint.h"
#import "MSAIEnums.h"

#if MSAI_FEATURE_CRASH_REPORTER
#endif


@implementation MSAIMetricsManager {

  id _appDidBecomeActiveObserver;
  id _appDidEnterBackgroundObserver;
  id _networkDidBecomeReachableObserver;
}


#pragma mark - Init

- (instancetype)initWithAppContext:(MSAIContext *)appContext appClient:(MSAIAppClient *)appClient {
  if (self = [super initWithAppContext:appContext]) {
    _appClient = appClient;
    _telemetryChannel = [[MSAIChannel alloc] initWithAppClient:_appClient telemetryContext:[self telemetryContext]];
  }
  return self;
}

- (void)dealloc {
  [self unregisterObservers];
}


#pragma mark - Observers

- (void) registerObservers {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  __weak typeof(self) weakSelf = self;
  if (nil == _appDidEnterBackgroundObserver) {
    _appDidEnterBackgroundObserver = [nc addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                     object:nil
                                                      queue:NSOperationQueue.mainQueue
                                                 usingBlock:^(NSNotification *note) {
                                                   typeof(self) strongSelf = weakSelf;
                                                   [strongSelf updateSessionDate];
                                                 }];
  }
  if (nil == _appDidBecomeActiveObserver) {
    _appDidBecomeActiveObserver = [nc addObserverForName:UIApplicationWillEnterForegroundNotification
                                                  object:nil
                                                   queue:NSOperationQueue.mainQueue
                                              usingBlock:^(NSNotification *note) {
                                                typeof(self) strongSelf = weakSelf;
                                                [strongSelf renewSessionDate];
                                              }];
  }
  if (nil == _networkDidBecomeReachableObserver) {
    _networkDidBecomeReachableObserver = [nc addObserverForName:MSAINetworkDidBecomeReachableNotification
                                                         object:nil
                                                          queue:NSOperationQueue.mainQueue
                                                     usingBlock:^(NSNotification *note) {
                                                       typeof(self) strongSelf = weakSelf;
                                                       [strongSelf renewSessionDate];
                                                     }];
  }
}

- (void) unregisterObservers {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  if (_appDidEnterBackgroundObserver) {
    [nc removeObserver:_appDidEnterBackgroundObserver];
    _appDidEnterBackgroundObserver = nil;
  }
  if (_appDidBecomeActiveObserver) {
    [nc removeObserver:_appDidBecomeActiveObserver];
    _appDidBecomeActiveObserver = nil;
  }
  if (_networkDidBecomeReachableObserver) {
    [nc removeObserver:_networkDidBecomeReachableObserver];
    _networkDidBecomeReachableObserver = nil;
  }
}

#pragma mark - Private

- (void)trackDataItem:(MSAITelemetryData *)dataItem{
  if ([self isMetricsManagerDisabled]) return;
  [_telemetryChannel sendDataItem:dataItem];
}

- (MSAITelemetryContext *)telemetryContext{
  
  MSAIDevice *deviceContext = [MSAIDevice new];
  [deviceContext setModel: [self.appContext deviceModel]];
  [deviceContext setType:[self.appContext deviceType]];
  [deviceContext setOsVersion:[self.appContext osVersion]];
  [deviceContext setOs:[self.appContext osName]];
  [deviceContext setDeviceId:msai_appAnonID()];
  [deviceContext setOemName:@"Apple"];
  
  MSAIInternal *internalContext = [MSAIInternal new];
  [internalContext setSdkVersion: msai_sdkVersion()];
  
  MSAIApplication *applicationContext = [MSAIApplication new];
  [applicationContext setVersion:[self.appContext appVersion]];

  MSAISession *sessionContext = [MSAISession new];
  [sessionContext setSessionId:[self.appContext deviceType]];
  
  MSAIOperation *operationContext = [MSAIOperation new];
  MSAIUser *userContext = [MSAIUser new];
  MSAILocation *locationContext = [MSAILocation new];
  
  
  //TODO: Add additional context data
  MSAITelemetryContext *telemetryContext = [[MSAITelemetryContext alloc]initWithInstrumentationKey:[self.appContext instrumentationKey]
                                                                             endpointPath:MSAI_TELEMETRY_PATH
                                                                       applicationContext:applicationContext
                                                                            deviceContext:deviceContext
                                                                          locationContext:locationContext
                                                                           sessionContext:sessionContext
                                                                              userContext:userContext
                                                                          internalContext:internalContext
                                                                         operationContext:operationContext];
  return telemetryContext;
}

#pragma mark - Usage

-(void)trackEventWithName:(NSString *)eventName{
  [self trackEventWithName:eventName properties:nil mesurements:nil];
}

-(void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties{
  [self trackEventWithName:eventName properties:properties mesurements:nil];
}

-(void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties mesurements:(NSDictionary *)measurements{
  //TODO: Add custom initializer to MSAIEventData
  MSAIEventData *eventData = [MSAIEventData new];
  [eventData setName:eventName];
  [eventData setProperties:properties];
  [eventData setMeasurements:measurements];
  
  [self trackDataItem:eventData];
}

-(void)trackTraceWithMessage:(NSString *)message{
  [self trackTraceWithMessage:message properties:nil];
}

-(void)trackTraceWithMessage:(NSString *)message properties:(NSDictionary *)properties{
  //TODO: Add custom initializer to MSAIMessageData
  MSAIMessageData *messageData = [MSAIMessageData new];
  [messageData setMessage:message];
  [messageData setProperties:properties];
  
  [self trackDataItem:messageData];
}

-(void)trackMetricWithName:(NSString *)metricName value:(double)value{
  [self trackMetricWithName:metricName value:value properties:nil];
}

-(void)trackMetricWithName:(NSString *)metricName value:(double)value properties:(NSDictionary *)properties{
  
  //TODO: Add custom initializer to MSAIMetricData
  MSAIMetricData *metricData = [MSAIMetricData new];
  
  MSAIDataPoint *data = [MSAIDataPoint new];
  [data setCount:@(1)];
  [data setKind:MSAIDataPointType_measurement];
  [data setMax:@(value)];
  [data setName:metricName];
  [data setValue:@(value)];
  NSMutableArray *metrics = [NSMutableArray arrayWithObject:data];
  [metricData setMetrics:metrics];
  [metricData setProperties:properties];
  
  [self trackDataItem:metricData];
}

#pragma mark -

/**
 Begin the startup process
 */
- (void)startManager {
  if ([self isMetricsManagerDisabled]) return;
  [self registerObservers];
  
}

- (void)trackNewSessionEvent {
  [self trackEventWithName:@"Session Start Event"];
}

- (void)updateSessionDate {
  
}

- (void)renewSessionDate {
  [self trackNewSessionEvent];
}

@end

#endif
