#import "AppInsights.h"

#if MSAI_FEATURE_METRICS

#import "AppInsightsPrivate.h"
#import "MSAIHelper.h"

#import "MSAIMetricsManagerPrivate.h"
#import "MSAIChannel.h"
#import "MSAIChannelPrivate.h"
#import "MSAITelemetryContext.h"
#import "MSAITelemetryContextPrivate.h"
#import "MSAIContext.h"
#import "MSAIContextPrivate.h"
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
#import "MSAIEnvelopeManager.h"
#import "MSAIEnvelopeManagerPrivate.h"

NSString *const kMSAIApplicationWasLaunched = @"MSAIApplicationWasLaunched";
static char *const MSAIMetricEventQueue = "com.microsoft.appInsights.metricEventQueue";
static NSString *const kMSAIApplicationDidEnterBackgroundTime = @"MSAIApplicationDidEnterBackgroundTime";
static NSInteger const defaultSessionExpirationTime = 20;


@implementation MSAIMetricsManager{
  id _appDidFinishLaunchingObserver;
  id _appWillEnterForegroundObserver;
  id _appDidEnterBackgroundObserver;
  id _appWillTerminateObserver;
}

#pragma mark - Configure manager

+ (instancetype)sharedManager {
  static MSAIMetricsManager *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [self new];
  });
  return sharedManager;
}

- (instancetype)init {
  if ((self = [super init])) {
    _metricEventQueue = dispatch_queue_create(MSAIMetricEventQueue,DISPATCH_QUEUE_CONCURRENT);
  }
  return self;
}

- (void)startManager {
  dispatch_barrier_sync(_metricEventQueue, ^{
    if(_metricsManagerDisabled)return;
    [self registerObservers];
    _managerInitialised = YES;
  });
}

#pragma mark - Track data

+ (void)trackEventWithName:(NSString *)eventName{
  [self trackEventWithName:eventName properties:nil mesurements:nil];
}

- (void)trackEventWithName:(NSString *)eventName{
  [self trackEventWithName:eventName properties:nil mesurements:nil];
}

+ (void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties{
  [self trackEventWithName:eventName properties:properties mesurements:nil];
}

- (void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties{
  [self trackEventWithName:eventName properties:properties mesurements:nil];
}

+ (void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties mesurements:(NSDictionary *)measurements{
  [[self sharedManager] trackEventWithName:eventName properties:properties mesurements:measurements];
}

- (void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties mesurements:(NSDictionary *)measurements{
  __weak typeof(self) weakSelf = self;
  dispatch_async(_metricEventQueue, ^{
    if(!_managerInitialised) return;
    
    typeof(self) strongSelf = weakSelf;
    MSAIEventData *eventData = [MSAIEventData new];
    [eventData setName:eventName];
    [eventData setProperties:properties];
    [eventData setMeasurements:measurements];
    [strongSelf trackDataItem:eventData];
  });
}

+ (void)trackTraceWithMessage:(NSString *)message{
  [self trackTraceWithMessage:message properties:nil];
}

- (void)trackTraceWithMessage:(NSString *)message{
  [self trackTraceWithMessage:message properties:nil];
}

+ (void)trackTraceWithMessage:(NSString *)message properties:(NSDictionary *)properties{
  [[self sharedManager] trackTraceWithMessage:message properties:properties];
}

- (void)trackTraceWithMessage:(NSString *)message properties:(NSDictionary *)properties{
  __weak typeof(self) weakSelf = self;
  dispatch_async(_metricEventQueue, ^{
    if(!_managerInitialised) return;
    
    typeof(self) strongSelf = weakSelf;
    MSAIMessageData *messageData = [MSAIMessageData new];
    [messageData setMessage:message];
    [messageData setProperties:properties];
    [strongSelf trackDataItem:messageData];
  });
}

+ (void)trackMetricWithName:(NSString *)metricName value:(double)value{
  [self trackMetricWithName:metricName value:value properties:nil];
}

- (void)trackMetricWithName:(NSString *)metricName value:(double)value{
  [self trackMetricWithName:metricName value:value properties:nil];
}

+ (void)trackMetricWithName:(NSString *)metricName value:(double)value properties:(NSDictionary *)properties{
  [[self sharedManager] trackMetricWithName:metricName value:value properties:properties];
}

- (void)trackMetricWithName:(NSString *)metricName value:(double)value properties:(NSDictionary *)properties{
  __weak typeof(self) weakSelf = self;
  dispatch_async(_metricEventQueue, ^{
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

+ (void)trackException:(NSException *)exception{
  [[self sharedManager]trackException:exception];
}

- (void)trackException:(NSException *)exception{
  pthread_t thread = pthread_self();

  dispatch_async(_metricEventQueue, ^{
    PLCrashReporterSignalHandlerType signalHandlerType = PLCrashReporterSignalHandlerTypeBSD;
    PLCrashReporterSymbolicationStrategy symbolicationStrategy = PLCrashReporterSymbolicationStrategyAll;
    MSAIPLCrashReporterConfig *config = [[MSAIPLCrashReporterConfig alloc] initWithSignalHandlerType: signalHandlerType
                                                                               symbolicationStrategy: symbolicationStrategy];
    MSAIPLCrashReporter *cm = [[MSAIPLCrashReporter alloc] initWithConfiguration:config];
    NSData *data = [cm generateLiveReportWithThread:pthread_mach_thread_np(thread)];
    MSAIPLCrashReport *report = [[MSAIPLCrashReport alloc] initWithData:data error:nil];
    MSAIEnvelope *envelope = [[MSAIEnvelopeManager sharedManager] envelopeForCrashReport:(PLCrashReport *)report exception:exception];
    [[MSAIChannel sharedChannel] processEnvelope:envelope withCompletionBlock:nil];
  });
}

+ (void)trackPageView:(NSString *)pageName {
  [self trackPageView:pageName duration:nil];
}

- (void)trackPageView:(NSString *)pageName {
  [self trackPageView:pageName duration:nil];
}

+ (void)trackPageView:(NSString *)pageName duration:(long)duration {
  [self trackPageView:pageName duration:duration properties:nil];
}

- (void)trackPageView:(NSString *)pageName duration:(long)duration {
  [self trackPageView:pageName duration:duration properties:nil];
}

+ (void)trackPageView:(NSString *)pageName duration:(long)duration properties:(NSDictionary *)properties {
  [[self sharedManager]trackPageView:pageName duration:duration properties:properties];
}

- (void)trackPageView:(NSString *)pageName duration:(long)duration properties:(NSDictionary *)properties {
  __weak typeof(self) weakSelf = self;
  dispatch_async(_metricEventQueue, ^{
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

- (void)trackDataItem:(MSAITelemetryData *)dataItem{
  
  if(![[MSAIChannel sharedChannel] isQueueBusy]){
    MSAIEnvelope *envelope = [[MSAIEnvelopeManager sharedManager] envelopeForTelemetryData:dataItem];
    [[MSAIChannel sharedChannel] enqueueEnvelope:envelope];
  }
}

#pragma mark - Session update

//TODO unregister Obeservers?!
- (void)registerObservers {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  __weak typeof(self) weakSelf = self;
  if (nil == _appDidFinishLaunchingObserver) {
    _appDidFinishLaunchingObserver = [nc addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                    object:nil
                                                     queue:NSOperationQueue.mainQueue
                                                usingBlock:^(NSNotification *note) {
                                                  typeof(self) strongSelf = weakSelf;
                                                  [strongSelf startSession];
                                                }];
  }
  if (nil == _appDidEnterBackgroundObserver) {
    _appDidEnterBackgroundObserver = [nc addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                    object:nil
                                                     queue:NSOperationQueue.mainQueue
                                                usingBlock:^(NSNotification *note) {
                                                  typeof(self) strongSelf = weakSelf;
                                                  [strongSelf updateSessionDate];
                                                }];
  }
  if (nil == _appWillEnterForegroundObserver) {
    _appWillEnterForegroundObserver = [nc addObserverForName:UIApplicationWillEnterForegroundNotification
                                                     object:nil
                                                      queue:NSOperationQueue.mainQueue
                                                 usingBlock:^(NSNotification *note) {
                                                   typeof(self) strongSelf = weakSelf;
                                                   [strongSelf startSession];
                                                 }];
  }
  if (nil == _appWillTerminateObserver) {
    _appWillTerminateObserver = [nc addObserverForName:UIApplicationWillTerminateNotification
                                               object:nil
                                                queue:NSOperationQueue.mainQueue
                                           usingBlock:^(NSNotification *note) {
                                             typeof(self) strongSelf = weakSelf;
                                             [strongSelf endSession];
                                           }];
  }
}

- (void)updateSessionDate {
  [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:kMSAIApplicationDidEnterBackgroundTime];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)startSession {
  double appDidEnterBackgroundTime = [[NSUserDefaults standardUserDefaults] doubleForKey:kMSAIApplicationDidEnterBackgroundTime];
  double timeSinceLastBackground = [[NSDate date] timeIntervalSince1970] - appDidEnterBackgroundTime;
  if (timeSinceLastBackground > defaultSessionExpirationTime) {
    [[MSAIEnvelopeManager sharedManager] createNewSession];
    [self trackEventWithName:@"Session Start Event"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMSAIApplicationWasLaunched];
  }
}

- (void)endSession {
  [self trackEventWithName:@"Session End Event"];
}

@end

#endif
