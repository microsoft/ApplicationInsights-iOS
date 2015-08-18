#import "ApplicationInsights.h"

#if MSAI_FEATURE_TELEMETRY

#import "ApplicationInsightsPrivate.h"
#import "MSAIHelper.h"

#import "MSAITelemetryManagerPrivate.h"
#import "MSAIChannel.h"
#import "MSAIChannelPrivate.h"
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAIEventData.h"
#import "MSAIMessageData.h"
#import "MSAIMetricData.h"
#import "MSAIPageViewData.h"
#import "MSAIDataPoint.h"
#import "MSAIEnums.h"
#import "MSAICrashDataProvider.h"
#import "MSAICrashData.h"
#import <pthread.h>
#import <CrashReporter/CrashReporter.h>
#import "MSAIEnvelope.h"
#import "MSAIEnvelopeManager.h"
#import "MSAIEnvelopeManagerPrivate.h"
#import "MSAIContextHelper.h"
#import "MSAIContextHelperPrivate.h"
#import "MSAISessionStateData.h"
#import "MSAIOrderedDictionary.h"

static char *const MSAITelemetryEventQueue = "com.microsoft.ApplicationInsights.telemetryEventQueue";

@implementation MSAITelemetryManager {
  id _appDidEnterBackgroundObserver;
  id _appWillResignActiveObserver;
  id _sessionStartedObserver;
  id _sessionEndedObserver;
}

@synthesize commonProperties = _commonProperties;

#pragma mark - Configure manager

+ (instancetype)sharedManager {
  static MSAITelemetryManager *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [self new];
  });
  return sharedManager;
}

- (instancetype)init {
  if((self = [super init])) {
    _telemetryEventQueue = dispatch_queue_create(MSAITelemetryEventQueue, DISPATCH_QUEUE_CONCURRENT);
    _commonProperties = [NSDictionary new];
  }
  return self;
}

- (void)startManager {
  dispatch_barrier_sync(_telemetryEventQueue, ^{
    if(_telemetryManagerDisabled)return;
    [self registerObservers];
    _managerInitialised = YES;
  });
}

- (void)registerObservers {
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  __weak typeof(self) weakSelf = self;

  if(!_appDidEnterBackgroundObserver) {
    _appDidEnterBackgroundObserver = [center addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                         object:nil
                                                          queue:NSOperationQueue.mainQueue
                                                     usingBlock:^(NSNotification *notification) {
                                                       [[MSAIChannel sharedChannel] persistDataItemQueue];
                                                     }];
  }

  if(!_appWillResignActiveObserver) {
    _appWillResignActiveObserver = [center addObserverForName:UIApplicationWillResignActiveNotification
                                                       object:nil
                                                        queue:NSOperationQueue.mainQueue
                                                   usingBlock:^(NSNotification *notification) {
                                                     [[MSAIChannel sharedChannel] persistDataItemQueue];
                                                   }];
  }

  if(!_sessionStartedObserver) {
    _sessionStartedObserver = [center addObserverForName:MSAISessionStartedNotification
                                                  object:nil
                                                   queue:NSOperationQueue.mainQueue
                                              usingBlock:^(NSNotification *notification) {
                                                typeof(self) strongSelf = weakSelf;
                                                [strongSelf trackSessionStart];
                                              }];
  }
  if(!_sessionEndedObserver) {
    _sessionEndedObserver = [center addObserverForName:MSAISessionEndedNotification
                                                object:nil
                                                 queue:NSOperationQueue.mainQueue
                                            usingBlock:^(NSNotification *notification) {
                                              typeof(self) strongSelf = weakSelf;

                                              [strongSelf trackSessionEnd];
                                            }];
  }
}

- (void)unregisterObservers {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  _sessionStartedObserver = nil;
  _sessionEndedObserver = nil;
}

#pragma mark - Common Properties

+ (void)setCommonProperties:(NSDictionary *)commonProperties {
  [[self sharedManager] setCommonProperties:commonProperties];
}

- (void)setCommonProperties:(NSDictionary *)commonProperties {
  dispatch_barrier_async(_telemetryEventQueue, ^{
    _commonProperties = commonProperties;
  });
}

- (NSDictionary *)commonProperties {
  __block NSDictionary *properties = nil;
  dispatch_sync(_telemetryEventQueue, ^{
    properties = _commonProperties.copy;
  });
  return properties;
}

#pragma mark - Configuring modules
+ (void)setTelemetryManagerDisabled:(BOOL)telemetryManagerDisabled {
  [[self sharedManager] setTelemetryManagerDisabled:telemetryManagerDisabled];
}

- (void)setTelemetryManagerDisabled:(BOOL)telemetryManagerDisabled {
	dispatch_barrier_sync(_telemetryEventQueue, ^{
		_telemetryManagerDisabled = telemetryManagerDisabled;
    if(_telemetryManagerDisabled){
      [self unregisterObservers];
    }else{
      [self registerObservers];
    }
	});
}

- (BOOL)telemetryManagerDisabled {
  __block BOOL disabled = NO;
  dispatch_sync(_telemetryEventQueue, ^{
      disabled = _telemetryManagerDisabled;
  });
  return disabled;
}

+ (void)setAutoPageViewTrackingDisabled:(BOOL)autoPageViewTrackingDisabled {
  [[self sharedManager] setAutoPageViewTrackingDisabled:autoPageViewTrackingDisabled];
}

- (void)setAutoPageViewTrackingDisabled:(BOOL)autoPageViewTrackingDisabled {
	dispatch_barrier_sync(_telemetryEventQueue, ^{
		_autoPageViewTrackingDisabled = autoPageViewTrackingDisabled;
	});
}

- (BOOL)autoPageViewTrackingDisabled {
  __block BOOL disabled = NO;
  dispatch_sync(_telemetryEventQueue, ^{
    disabled = _autoPageViewTrackingDisabled;
  });
  return disabled;
}

+ (void)setAutoSessionManagementDisabled:(BOOL)autoSessionManagementDisabled {
  [[self sharedManager] setAutoSessionManagementDisabled:autoSessionManagementDisabled];
}

- (void)setAutoSessionManagementDisabled:(BOOL)autoSessionManagementDisabled {
	dispatch_barrier_sync(_telemetryEventQueue, ^{
		_autoSessionManagementDisabled = autoSessionManagementDisabled;
  [MSAIContextHelper sharedInstance].autoSessionManagementDisabled = autoSessionManagementDisabled;
	});
}

- (BOOL)autoSessionManagementDisabled {
  __block BOOL disabled = NO;
  dispatch_sync(_telemetryEventQueue, ^{
    disabled = _autoSessionManagementDisabled;
  });
  return disabled;
}

#pragma mark - Track data

+ (void)trackEventWithName:(NSString *)eventName {
  [self trackEventWithName:eventName properties:nil measurements:nil];
}

- (void)trackEventWithName:(NSString *)eventName {
  [self trackEventWithName:eventName properties:nil measurements:nil];
}

+ (void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties {
  [self trackEventWithName:eventName properties:properties measurements:nil];
}

- (void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties {
  [self trackEventWithName:eventName properties:properties measurements:nil];
}

+ (void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties measurements:(NSDictionary *)measurements {
  [[self sharedManager] trackEventWithName:eventName properties:properties measurements:measurements];
}

- (void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties measurements:(NSDictionary *)measurements {
  __weak typeof(self) weakSelf = self;
  dispatch_async(_telemetryEventQueue, ^{
    if(!_managerInitialised) return;

    typeof(self) strongSelf = weakSelf;
    MSAIEventData *eventData = [MSAIEventData new];
    [eventData setName:eventName];
    [eventData setProperties:properties];
    [eventData setMeasurements:measurements];
    [strongSelf trackDataItem:eventData];
  });
}

+ (void)trackTraceWithMessage:(NSString *)message {
  [self trackTraceWithMessage:message properties:nil];
}

- (void)trackTraceWithMessage:(NSString *)message {
  [self trackTraceWithMessage:message properties:nil];
}

+ (void)trackTraceWithMessage:(NSString *)message properties:(NSDictionary *)properties {
  [[self sharedManager] trackTraceWithMessage:message properties:properties];
}

- (void)trackTraceWithMessage:(NSString *)message properties:(NSDictionary *)properties {
  __weak typeof(self) weakSelf = self;
  dispatch_async(_telemetryEventQueue, ^{
    if(!_managerInitialised) return;

    typeof(self) strongSelf = weakSelf;
    MSAIMessageData *messageData = [MSAIMessageData new];
    [messageData setMessage:message];
    [messageData setProperties:properties];
    [strongSelf trackDataItem:messageData];
  });
}

+ (void)trackMetricWithName:(NSString *)metricName value:(double)value {
  [self trackMetricWithName:metricName value:value properties:nil];
}

- (void)trackMetricWithName:(NSString *)metricName value:(double)value {
  [self trackMetricWithName:metricName value:value properties:nil];
}

+ (void)trackMetricWithName:(NSString *)metricName value:(double)value properties:(NSDictionary *)properties {
  [[self sharedManager] trackMetricWithName:metricName value:value properties:properties];
}

- (void)trackMetricWithName:(NSString *)metricName value:(double)value properties:(NSDictionary *)properties {
  __weak typeof(self) weakSelf = self;
  dispatch_async(_telemetryEventQueue, ^{
    if(!_managerInitialised) return;

    typeof(self) strongSelf = weakSelf;
    MSAIMetricData *metricData = [MSAIMetricData new];
    MSAIDataPoint *data = [MSAIDataPoint new];
    [data setCount:@(1)];
    [data setKind:MSAIDataPointType_measurement];
    [data setMax:@(value)];
    [data setName:metricName];
    [data setValue:@(value)];
    NSMutableArray *metrics = [@[data] mutableCopy];
    [metricData setMetrics:metrics];
    [metricData setProperties:properties];
    [strongSelf trackDataItem:metricData];
  });
}

+ (void)trackException:(NSException *)exception {
  [[self sharedManager] trackException:exception];
}

- (void)trackException:(NSException *)exception {
  pthread_t thread = pthread_self();

  dispatch_async(_telemetryEventQueue, ^{
    PLCrashReporterSignalHandlerType signalHandlerType = PLCrashReporterSignalHandlerTypeBSD;
    PLCrashReporterSymbolicationStrategy symbolicationStrategy = PLCrashReporterSymbolicationStrategyAll;
    MSAIPLCrashReporterConfig *config = [[MSAIPLCrashReporterConfig alloc] initWithSignalHandlerType:signalHandlerType
                                                                               symbolicationStrategy:symbolicationStrategy];
    MSAIPLCrashReporter *cm = [[MSAIPLCrashReporter alloc] initWithConfiguration:config];
    NSData *data = [cm generateLiveReportWithThread:pthread_mach_thread_np(thread)];
    MSAIPLCrashReport *report = [[MSAIPLCrashReport alloc] initWithData:data error:nil];
    MSAIEnvelope *envelope = [[MSAIEnvelopeManager sharedManager] envelopeForCrashReport:report exception:exception];
    MSAIOrderedDictionary *dict = [envelope serializeToDictionary];
    [[MSAIChannel sharedChannel] processDictionary:dict withCompletionBlock:nil];
  });
}

+ (void)trackPageView:(NSString *)pageName {
  [self trackPageView:pageName duration:0];
}

- (void)trackPageView:(NSString *)pageName {
  [self trackPageView:pageName duration:0];
}

+ (void)trackPageView:(NSString *)pageName duration:(long)duration {
  [self trackPageView:pageName duration:duration properties:nil];
}

- (void)trackPageView:(NSString *)pageName duration:(long)duration {
  [self trackPageView:pageName duration:duration properties:nil];
}

+ (void)trackPageView:(NSString *)pageName duration:(long)duration properties:(NSDictionary *)properties {
  [[self sharedManager] trackPageView:pageName duration:duration properties:properties];
}

- (void)trackPageView:(NSString *)pageName duration:(long)duration properties:(NSDictionary *)properties {
  __weak typeof(self) weakSelf = self;
  dispatch_async(_telemetryEventQueue, ^{
    if(!_managerInitialised) return;

    typeof(self) strongSelf = weakSelf;
    MSAIPageViewData *pageViewData = [MSAIPageViewData new];
    pageViewData.name = pageName;
    pageViewData.duration = [NSString stringWithFormat:@"%ld", duration];
    pageViewData.properties = properties;
    [strongSelf trackDataItem:pageViewData];
  });
}

#pragma mark Track DataItem

- (void)trackDataItem:(MSAITelemetryData *)dataItem {
  if(![[MSAIChannel sharedChannel] isQueueBusy]) {
    [self addCommonPropertiesToDataItem:dataItem];
    MSAIEnvelope *envelope = [[MSAIEnvelopeManager sharedManager] envelopeForTelemetryData:dataItem];
    MSAIOrderedDictionary *dict = [envelope serializeToDictionary];
    [[MSAIChannel sharedChannel] enqueueDictionary:dict];
  } else {
    if (dataItem && dataItem.name) {
      MSAILog(@"The data pipeline is saturated right now and the data item named %@ was dropped.", dataItem.name);
    }
  }
}

- (void)addCommonPropertiesToDataItem:(MSAITelemetryData *)dataItem {
  NSMutableDictionary *mergedProperties = self.commonProperties.mutableCopy;
  [mergedProperties addEntriesFromDictionary:dataItem.properties];
  dataItem.properties = mergedProperties;
}

#pragma mark - Session update

- (void)trackSessionStart {
  MSAISessionStateData *sessionState = [MSAISessionStateData new];
  sessionState.state = MSAISessionState_start;
  //updating IsNew tag from session context doesn't work because editing NSUserDefaults
  //doesn't happen timely enough so we can be sure isNew is true for all cases
  //so we set it to true explicitly
  if(![[MSAIChannel sharedChannel] isQueueBusy]) {
    [self addCommonPropertiesToDataItem:sessionState];
    MSAIEnvelope *envelope = [[MSAIEnvelopeManager sharedManager] envelopeForTelemetryData:sessionState];

    envelope.tags[@"ai.session.isNew"] = @"true";
    MSAIOrderedDictionary *dict = [envelope serializeToDictionary];
    [[MSAIChannel sharedChannel] enqueueDictionary:dict];
  }
}


- (void)trackSessionEnd {
  MSAISessionStateData *sessionState = [MSAISessionStateData new];
  sessionState.state = MSAISessionState_end;
  [self trackDataItem:sessionState];
}

@end

#endif
