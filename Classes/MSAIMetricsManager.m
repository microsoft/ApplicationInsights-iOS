#import "AppInsights.h"

#if MSAI_FEATURE_METRICS

#import "AppInsightsPrivate.h"
#import "MSAIHelper.h"

#import "MSAIBaseManagerPrivate.h"
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
#import "MSAIExceptionFormatter.h"
#import "MSAICrashData.h"
#import <pthread.h>
#import <CrashReporter/CrashReporter.h>
#import "MSAIEnvelopeManager.h"
#import "MSAIEnvelopeManagerPrivate.h"


#if MSAI_FEATURE_CRASH_REPORTER
#endif

NSString *const kMSAIApplicationWasLaunched = @"MSAIApplicationWasLaunched";
static NSString *const kMSAIApplicationDidEnterBackgroundTime = @"MSAIApplicationDidEnterBackgroundTime";
static NSInteger const defaultSessionExpirationTime = 20;

static dispatch_queue_t metricEventQueue;
static BOOL disableMetricsManager;
static BOOL managerInitialised = NO;

static id appDidFinishLaunchingObserver;
static id appWillEnterForegroundObserver;
static id appDidEnterBackgroundObserver;
static id appWillTerminateObserver;

@implementation MSAIMetricsManager

#pragma mark - Configure manager

+ (void)setDisableMetricsManager:(BOOL)disable{
  dispatch_barrier_async(metricEventQueue, ^{
    disableMetricsManager = disable;
  });
}

+ (void)startManager {
  if(disableMetricsManager) return;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    metricEventQueue = dispatch_queue_create("com.microsoft.appInsights.metricEventQueue",DISPATCH_QUEUE_CONCURRENT);
  });
  
  dispatch_barrier_sync(metricEventQueue, ^{
    [self registerObservers];
    managerInitialised = YES;
  });
}

#pragma mark - Track data

+(void)trackEventWithName:(NSString *)eventName{
  [self trackEventWithName:eventName properties:nil mesurements:nil];
}

+(void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties{
  [self trackEventWithName:eventName properties:properties mesurements:nil];
}

+(void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties mesurements:(NSDictionary *)measurements{
  if(!managerInitialised) return;
  
  __weak typeof(self) weakSelf = self;
  dispatch_async(metricEventQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    MSAIEventData *eventData = [MSAIEventData new];
    [eventData setName:eventName];
    [eventData setProperties:properties];
    [eventData setMeasurements:measurements];
    [strongSelf trackDataItem:eventData];
  });
}

+(void)trackTraceWithMessage:(NSString *)message{
  [self trackTraceWithMessage:message properties:nil];
}

+(void)trackTraceWithMessage:(NSString *)message properties:(NSDictionary *)properties{
  if(!managerInitialised) return;
  
  __weak typeof(self) weakSelf = self;
  dispatch_async(metricEventQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    MSAIMessageData *messageData = [MSAIMessageData new];
    [messageData setMessage:message];
    [messageData setProperties:properties];
    [strongSelf trackDataItem:messageData];
  });
}

+(void)trackMetricWithName:(NSString *)metricName value:(double)value{
  [self trackMetricWithName:metricName value:value properties:nil];
}

+(void)trackMetricWithName:(NSString *)metricName value:(double)value properties:(NSDictionary *)properties{
  if(!managerInitialised) return;
  
  __weak typeof(self) weakSelf = self;
  dispatch_async(metricEventQueue, ^{
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
  
  
  
  PLCrashReporterSignalHandlerType signalHandlerType = PLCrashReporterSignalHandlerTypeBSD;
  
  PLCrashReporterSymbolicationStrategy symbolicationStrategy = PLCrashReporterSymbolicationStrategyAll;
  
  MSAIPLCrashReporterConfig *config = [[MSAIPLCrashReporterConfig alloc] initWithSignalHandlerType: signalHandlerType
                                                                             symbolicationStrategy: symbolicationStrategy];
  NSError *error = NULL;
  MSAIPLCrashReporter *cm = [[MSAIPLCrashReporter alloc] initWithConfiguration:config];
  NSData *data = [cm generateLiveReportWithThread:pthread_mach_thread_np(pthread_self())];
  MSAIPLCrashReport *report = [[MSAIPLCrashReport alloc] initWithData:data error:&error];
  
  __weak typeof(self) weakSelf = self;
  dispatch_async(metricEventQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    MSAICrashData *exceptionData = [MSAIExceptionFormatter crashDataForCrashReport:report crashReporterKey:nil handledException:exception];
    [strongSelf trackDataItem:exceptionData];
  });
}

#pragma mark - PageView

+ (void)trackPageView:(NSString *)pageName {
  [self trackPageView:pageName duration:nil];
}

+ (void)trackPageView:(NSString *)pageName duration:(long)duration {
  [self trackPageView:pageName duration:duration properties:nil];
}

+ (void)trackPageView:(NSString *)pageName duration:(long)duration properties:(NSDictionary *)properties {
  if(!managerInitialised) return;
  
  __weak typeof(self) weakSelf = self;
  dispatch_async(metricEventQueue, ^{
    typeof(self) strongSelf = weakSelf;
    
    MSAIPageViewData *pageViewData = [MSAIPageViewData new];
    pageViewData.name = pageName;
    pageViewData.duration = [NSString stringWithFormat:@"%ld", duration];
    pageViewData.properties = properties;
    [strongSelf trackDataItem:pageViewData];
  });
}

#pragma mark Track DataItem

+ (void)trackDataItem:(MSAITelemetryData *)dataItem{
  if(disableMetricsManager || !managerInitialised) return;
  
  MSAIEnvelope *envelope = [[MSAIEnvelopeManager sharedManager] envelopeForTelemetryData:dataItem];
  [[MSAIChannel sharedChannel] enqueueEnvelope:envelope highPriority:NO];
}

#pragma mark - Session update

+ (void) registerObservers {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  __weak typeof(self) weakSelf = self;
  if (nil == appDidFinishLaunchingObserver) {
    appDidFinishLaunchingObserver = [nc addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                    object:nil
                                                     queue:NSOperationQueue.mainQueue
                                                usingBlock:^(NSNotification *note) {
                                                  typeof(self) strongSelf = weakSelf;
                                                  [strongSelf startSession];
                                                }];
  }
  if (nil == appDidEnterBackgroundObserver) {
    appDidEnterBackgroundObserver = [nc addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                    object:nil
                                                     queue:NSOperationQueue.mainQueue
                                                usingBlock:^(NSNotification *note) {
                                                  typeof(self) strongSelf = weakSelf;
                                                  [strongSelf updateSessionDate];
                                                }];
  }
  if (nil == appWillEnterForegroundObserver) {
    appWillEnterForegroundObserver = [nc addObserverForName:UIApplicationWillEnterForegroundNotification
                                                     object:nil
                                                      queue:NSOperationQueue.mainQueue
                                                 usingBlock:^(NSNotification *note) {
                                                   typeof(self) strongSelf = weakSelf;
                                                   [strongSelf startSession];
                                                 }];
  }
  if (nil == appWillTerminateObserver) {
    appWillTerminateObserver = [nc addObserverForName:UIApplicationWillTerminateNotification
                                               object:nil
                                                queue:NSOperationQueue.mainQueue
                                           usingBlock:^(NSNotification *note) {
                                             typeof(self) strongSelf = weakSelf;
                                             [strongSelf endSession];
                                           }];
  }
}

+ (void)updateSessionDate {
  [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:kMSAIApplicationDidEnterBackgroundTime];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)startSession {
  double appDidEnterBackgroundTime = [[NSUserDefaults standardUserDefaults] doubleForKey:kMSAIApplicationDidEnterBackgroundTime];
  double timeSinceLastBackground = [[NSDate date] timeIntervalSince1970] - appDidEnterBackgroundTime;
  if (timeSinceLastBackground > defaultSessionExpirationTime) {
    [[MSAIEnvelopeManager sharedManager] createNewSession];
    [self trackEventWithName:@"Session Start Event"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMSAIApplicationWasLaunched];
  }
}

+ (void)endSession {
  [self trackEventWithName:@"Session End Event"];
}

#pragma mark - Helper

+ (BOOL)isMangerAvailable{
  return !disableMetricsManager && managerInitialised;
}

@end

#endif
