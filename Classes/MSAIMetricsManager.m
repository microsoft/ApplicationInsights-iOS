#import "AppInsights.h"

#if MSAI_FEATURE_METRICS

#import "AppInsightsPrivate.h"

#import "MSAIHelper.h"

#import "MSAIBaseManagerPrivate.h"
#import "MSAIMetricsManagerPrivate.h"
#import "MSAIMetricsSession.h"
#import "MSAIChannel.h"
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

NSString *const kMSAIMetricsCachesSessions = @"MSAIMetricsCachesSessions";
NSString *const kMSAIMetricsTempSessionData = @"MSAIMetricsTempSessionData";
NSString *const kMSAIMetricsLastAppVersion = @"MSAIMetricsLastAppVersion";


@implementation MSAIMetricsManager {
  NSFileManager  *_fileManager;
  NSString       *_metricsDataFile;
  
  // Used for storing the current session details once started.
  NSString       *_metricsTempDataFile;
  
  // This is used to determine the session start time for crashed sessions
  MSAIMetricsSession *_previousTempSession;
  
  id _appDidBecomeActiveObserver;
  id _appDidEnterBackgroundObserver;
  id _appDidTerminateObserver;
  id _networkDidBecomeReachableObserver;
  
  BOOL _isSending;
  
  NSMutableArray *_cachedSessions;
}


#pragma mark - Init

- (id)init {
  if ((self = [super init])) {
//    _disableMetricsManager = NO;
//
//    _isSending = NO;
//    
//    
//    _currentSession = nil;
//    _cachedSessions = [[NSMutableArray alloc] init];
//    _previousTempSession = nil;
//    
//    // set defaults
//    _fileManager = [[NSFileManager alloc] init];
//    
//    _metricsDataFile = [msai_settingsDir() stringByAppendingPathComponent:MSAI_METRICS_DATA];
//    _metricsTempDataFile = [msai_settingsDir() stringByAppendingPathComponent:MSAI_METRICS_TEMP_DATA];
    

  }
  return self;
}

- (instancetype)initWithAppContext:(MSAIContext *)appContext appClient:(MSAIAppClient *)appClient {
  if (self = [super initWithAppContext:appContext]) {
    _appClient = appClient;
    _telemetryChannel = [[MSAIChannel alloc] initWithAppClient:_appClient telemetryContext:[self telemetryContext]];
  }
  return self;
}

- (void)dealloc {
//  [self unregisterObservers];
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
                                                   [strongSelf stopUsage];
                                                 }];
  }
  if (nil == _appDidTerminateObserver) {
    _appDidTerminateObserver = [nc addObserverForName:UIApplicationWillTerminateNotification
                                               object:nil
                                                queue:NSOperationQueue.mainQueue
                                           usingBlock:^(NSNotification *note) {
                                             typeof(self) strongSelf = weakSelf;
                                             [strongSelf stopUsage];
                                           }];
  }
  if (nil == _appDidBecomeActiveObserver) {
    _appDidBecomeActiveObserver = [nc addObserverForName:UIApplicationDidBecomeActiveNotification
                                                  object:nil
                                                   queue:NSOperationQueue.mainQueue
                                              usingBlock:^(NSNotification *note) {
                                                typeof(self) strongSelf = weakSelf;
                                                [strongSelf startUsage];
                                                [strongSelf sendDataInBackground];
                                              }];
  }
  if (nil == _networkDidBecomeReachableObserver) {
    _networkDidBecomeReachableObserver = [nc addObserverForName:MSAINetworkDidBecomeReachableNotification
                                                         object:nil
                                                          queue:NSOperationQueue.mainQueue
                                                     usingBlock:^(NSNotification *note) {
                                                       typeof(self) strongSelf = weakSelf;
                                                       [strongSelf sendDataInBackground];
                                                     }];
  }
}

- (void) unregisterObservers {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  if (_appDidEnterBackgroundObserver) {
    [nc removeObserver:_appDidEnterBackgroundObserver];
    _appDidEnterBackgroundObserver = nil;
  }
  if (_appDidTerminateObserver) {
    [nc removeObserver:_appDidTerminateObserver];
    _appDidTerminateObserver = nil;
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


#pragma mark - Storage

/**
 Load stored session data
 */
- (void)loadMetricsData {
  if (![_fileManager fileExistsAtPath:_metricsDataFile])
    return;
  
  NSData *codedData = [[NSData alloc] initWithContentsOfFile:_metricsDataFile];
  if (codedData == nil) return;
  
  NSKeyedUnarchiver *unarchiver = nil;
  
  @try {
    unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
  }
  @catch (NSException *exception) {
    return;
  }
  
  if ([unarchiver containsValueForKey:kMSAIMetricsCachesSessions]) {
    NSArray *sessions = [unarchiver decodeObjectForKey:kMSAIMetricsCachesSessions];
    if ([sessions count] > 0) {
      [_cachedSessions addObjectsFromArray:sessions];
    }
  }
  
  [unarchiver finishDecoding];
}

/**
 Store current session data into a cache file
 
 @return BOOL YES if storing succeeded
 */
- (BOOL)storeMetricsData {
  NSMutableData *data = [[NSMutableData alloc] init];
  NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
  
  [archiver encodeObject:_cachedSessions forKey:kMSAIMetricsCachesSessions];
  
  [archiver finishEncoding];
  BOOL result = [data writeToFile:_metricsDataFile atomically:YES];
  
  return result;
}


/**
 Load stored temp session data
 
 This only contains one started session details, so it can be used for crashed sessions
 */
- (void)loadMetricsTempData {
  if (![_fileManager fileExistsAtPath:_metricsTempDataFile])
    return;
  
  NSData *codedData = [[NSData alloc] initWithContentsOfFile:_metricsTempDataFile];
  if (codedData == nil) return;
  
  NSKeyedUnarchiver *unarchiver = nil;
  
  @try {
    unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
  }
  @catch (NSException *exception) {
    return;
  }
  
  if ([unarchiver containsValueForKey:kMSAIMetricsTempSessionData]) {
    id data = [unarchiver decodeObjectForKey:kMSAIMetricsTempSessionData];
    if ([data isKindOfClass:[MSAIMetricsSession class]]) {
      _previousTempSession = (MSAIMetricsSession *)data;
    }
  }
  
  [unarchiver finishDecoding];
  
  // now delete the temp file
  NSError *error = nil;
  [_fileManager removeItemAtPath:_metricsTempDataFile error:&error];
}

/**
 Store current sessions data into a temp file
 
 @return BOOL YES if storing succeeded
 */
- (BOOL)storeMetricsTempData {
  NSMutableData *data = [[NSMutableData alloc] init];
  NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
  
  [archiver encodeObject:_currentSession forKey:kMSAIMetricsTempSessionData];
  
  [archiver finishEncoding];
  BOOL result = [data writeToFile:_metricsTempDataFile atomically:YES];
  
  return result;
}


#pragma mark - Private

- (void)trackDataItem:(MSAITelemetryData *)dataItem{
  [_telemetryChannel sendDataItem:dataItem];
}

- (MSAITelemetryContext *)telemetryContext{
  
  MSAIDevice *deviceContext = [MSAIDevice new];
  
  [deviceContext setModel: [self.appContext deviceModel]];
  [deviceContext setType:[self.appContext deviceType]];
  [deviceContext setOsVersion:[self.appContext osVersion]];
  [deviceContext setOs:[self.appContext osName]];
  [deviceContext setDeviceId:msai_appAnonID()];
  
  MSAIInternal *internalContext = [MSAIInternal new];
  [internalContext setSdkVersion: msai_sdkVersion()];
  
  MSAIApplication *applicationContext = [MSAIApplication new];
  [applicationContext setVersion:[self.appContext appVersion]];

  //TODO: Add additional context data
  MSAITelemetryContext *telemetryContext = [[MSAITelemetryContext alloc]initWithInstrumentationKey:[self.appContext instrumentationKey]
                                                                             endpointPath:MSAI_TELEMETRY_PATH
                                                                       applicationContext:applicationContext
                                                                            deviceContext:deviceContext
                                                                          locationContext:nil
                                                                           sessionContext:nil
                                                                              userContext:nil
                                                                          internalContext:internalContext
                                                                         operationContext:nil];
  return telemetryContext;
}

/**
 Reset the first session value
 
 Use with caution!
 */
- (void) cleanupInternalStorage {
  [self removeKeyFromKeychain:kMSAIMetricsLastAppVersion];
}

#pragma mark - Usage

-(void)trackEventWithName:(NSString *)eventName{
  [self trackEventWithName:eventName properties:nil mesurements:nil];
}

-(void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties{
  [self trackEventWithName:eventName properties:properties mesurements:nil];
}

-(void)trackEventWithName:(NSString *)eventName properties:(NSDictionary *)properties mesurements:(NSDictionary *)measurements{
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
  MSAIMessageData *messageData = [MSAIMessageData new];
  [messageData setMessage:message];
  [messageData setProperties:properties];
  
  [self trackDataItem:messageData];
}

-(void)trackMetricWithName:(NSString *)metricName value:(double)value{
  [self trackMetricWithName:metricName value:value properties:nil];
}

-(void)trackMetricWithName:(NSString *)metricName value:(double)value properties:(NSDictionary *)properties{
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

/**
 A new session started
 */
- (void)startUsage {
//  if ([self isMetricsManagerDisabled]) return;
//  
//  if (_currentSession) return;
//  
//  UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
//  if (appState == UIApplicationStateBackground) return;
//  
//  NSUUID *installationUUID = [[NSUUID alloc] initWithUUIDString:msai_appAnonID()];
//
//  if (!installationUUID) return;
//  
//  NSBundle *appBundle = [NSBundle mainBundle];
//  
//  if (!appBundle) return;
//  
//  NSDate *sessionStartDate = [NSDate date];
//  uint64_t sessionStartTime = (uint64_t)[sessionStartDate timeIntervalSince1970] * 1000; // CFAbsoluteTimeGetCurrent();
//  
//  // these values can only change via app starts
//  NSString *sessionAppLang = @"unknown";
//  NSArray *appLocalizations = [appBundle preferredLocalizations];
//  if (appLocalizations && [appLocalizations count] > 0) {
//    sessionAppLang = [appLocalizations objectAtIndex:0];
//  }
//  
//  NSString *sessionAppBuild = [appBundle objectForInfoDictionaryKey:@"CFBundleVersion"] ?: @"";
//  NSString *sessionAppVersion = [appBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"";
//  
//  NSString *sessionDeviceLocale = [[NSLocale currentLocale] localeIdentifier];
//  NSString *sessionDeviceModel = [self getDevicePlatform];
//  NSString *sessionDeviceOS = [[UIDevice currentDevice] systemVersion];
//  
//  BOOL firstSessionForAppVersion = NO;
//  
//  NSString *previousSessionAppVersion = [self stringValueFromKeychainForKey:kMSAIMetricsLastAppVersion];
//  if (!previousSessionAppVersion || ![sessionAppBuild isEqualToString:previousSessionAppVersion]) {
//    firstSessionForAppVersion = YES;
//  }
//  
//  _currentSession = [[MSAIMetricsSession alloc] initWithInstallationUUID:installationUUID
//                                                                     deviceModel:sessionDeviceModel
//                                                                 deviceOSVersion:sessionDeviceOS
//                                                                    deviceLocale:sessionDeviceLocale
//                                                                     appLanguage:sessionAppLang
//                                                                        appBuild:sessionAppBuild
//                                                                      appVersion:sessionAppVersion
//                                                                sessionStartTime:sessionStartTime
//                                                                  sessionEndTime:0
//                                                                    firstSession:firstSessionForAppVersion
//                     ];
//  
//  [self storeMetricsTempData];
}

/**
 A session has ended
 */
- (void)stopUsage {
//  if ([self isMetricsManagerDisabled]) return;
//  
//  UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
//  if (appState != UIApplicationStateBackground) return;
//
//  if (!_currentSession) return;
//  
//  if (_currentSession.sessionStartTime == 0) return;
//  
//  uint64_t sessionEndTime = (uint64_t)[[NSDate date] timeIntervalSince1970] * 1000;
//  
//  MSAIMetricsSession *finishedSession = [[MSAIMetricsSession alloc] initWithInstallationUUID:_currentSession.installationUUID
//                                                                                                 deviceModel:_currentSession.deviceModel
//                                                                                             deviceOSVersion:_currentSession.deviceOSVersion
//                                                                                                deviceLocale:_currentSession.deviceLocale
//                                                                                                 appLanguage:_currentSession.appLanguage
//                                                                                                    appBuild:_currentSession.appBuild
//                                                                                                  appVersion:_currentSession.appVersion
//                                                                                            sessionStartTime:_currentSession.sessionStartTime
//                                                                                              sessionEndTime:sessionEndTime
//                                                                                                firstSession:_currentSession.firstSession
//                                                 ];
//  _currentSession = nil;
//
//  BOOL result = NO;
//  
//  @synchronized(@"MSAIMetricsSessionCache") {
//    [_cachedSessions addObject:finishedSession];
//  
//    result = [self storeMetricsData];
//  }
//  
//  if (result) {
//    
//    if (finishedSession.firstSession) {
//      [self addStringValueToKeychainForThisDeviceOnly:finishedSession.appBuild forKey:kMSAIMetricsLastAppVersion];
//    }
//    
//    [self sendDataInBackground];
//  }
}


/**
 Check if the last session crashed and create a session object for that if so
 */
- (void)processLastSessionIfCrashed {
#if MSAIDK_FEATURE_CRASH_REPORTER
  if (!_previousTempSession) return;
  
  BOOL didCrash = [[MSAITelemetryManager sharedManager].crashManager didCrashInLastSession];
  
  if (!didCrash) return;
  
  MSAICrashDetails *lastSessionCrashDetails = [[MSAITelemetryManager sharedManager].crashManager lastSessionCrashDetails];
  uint64_t sessionEndTime = (uint64_t)[[lastSessionCrashDetails crashTime] timeIntervalSince1970] * 1000;
  
  MSAIMetricsSession *crashedSession = [[MSAIMetricsSession alloc] initWithInstallationUUID:_previousTempSession.installationUUID
                                                                                                deviceModel:_previousTempSession.deviceModel
                                                                                            deviceOSVersion:_previousTempSession.deviceOSVersion
                                                                                               deviceLocale:_previousTempSession.deviceLocale
                                                                                                appLanguage:_previousTempSession.appLanguage
                                                                                                   appBuild:_previousTempSession.appBuild
                                                                                                 appVersion:_previousTempSession.appVersion
                                                                                           sessionStartTime:_previousTempSession.sessionStartTime
                                                                                             sessionEndTime:sessionEndTime
                                                                                               firstSession:_previousTempSession.firstSession
                                                ];
  
  
  @synchronized(@"MSAIMetricsSessionCache") {
    [_cachedSessions addObject:crashedSession];
    
    [self storeMetricsData];
  }
  
#endif
}


#pragma mark - Networking

/**
 Send a single dataset
 */
- (void)sendFinishedSessions {
//  MSAITelemetrySessionMetrics *session = _cachedSessions[0];
//  
//  __weak typeof(self) weakSelf = self;
//  [_client recordSession:session timeout:5 successHandler:^{
//    NSLog(@"Successfully submitted session metrics");
//    typeof(self) strongSelf = weakSelf;
//    
//    @synchronized(@"MSAIMetricsSessionCache") {
//      [_cachedSessions removeObjectAtIndex:0];
//      [strongSelf storeMetricsData];
//    }
//    
//    NSTimeInterval remainingTime = [UIApplication sharedApplication].backgroundTimeRemaining;
//    
//    if (remainingTime > 10 && [_cachedSessions count] > 0) {
//      UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
//      if (appState != UIApplicationStateBackground) {
//        [strongSelf sendFinishedSessions];
//        return;
//      }
//    }
//    
//    [strongSelf endSendingDataInBackground];
//
//  } failureHandler:^(NSError *error) {
//    typeof(self) strongSelf = weakSelf;
//
//    NSLog(@"Failed submitting session");
//    
//    [strongSelf endSendingDataInBackground];
//
//  }];
}


/**
 Connect to the server and start sending available data
 */
- (void)setupTelemetryClientAndSendData {
//  __weak typeof(self) weakSelf = self;
//  MSAITelemetryClientConfig *config = [[MSAITelemetryClientConfig alloc] initWithHost:kMSAISDKMetricsHostname port:kMSAISDKMetricsPort];
//  [MSAITelemetryClient authenticateWithConfig:config
//                                       appID:self.appIdentifier
//                                     timeout:5
//                                handlerQueue:dispatch_get_main_queue()
//                              successHandler:^(MSAITelemetryClient *client) {
//                                typeof(self) strongSelf = weakSelf;
//                                /* Authentication succeeded; record some sessions */
//                                _client = client;
//                                [strongSelf sendFinishedSessions];
//
//                              }
//                              failureHandler:^(NSError *error) {
//                                typeof(self) strongSelf = weakSelf;
//
//                                if (error.domain == MSAITelemetryClientErrorDomain) {
//                                  if (error.code == MSAITelemetryClientErrorAuthFailed) {
//                                    /* Authentication failed */
//                                  }
//                                }
//
//                                NSLog(@"Auth failed due to error: %@", error);
//                                
//                                [strongSelf endSendingDataInBackground];
//                              }];
}


/**
 End a background task for sending data
 */
- (void)endSendingDataInBackground {
//  if (_client) {
//    [_client disconnect];
//    _client = nil;
//  }
  
  _isSending = NO;
  
  if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
  }
}

/**
 Control sending data in background
 */
- (void)sendDataInBackground {
  if ([self isMetricsManagerDisabled]) return;
  
  if (_isSending) return;

  if ([_cachedSessions count] == 0) {
    return;
  }
  
  _isSending = YES;

  __weak typeof(self) weakSelf = self;
  self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    dispatch_async(dispatch_get_main_queue(), ^{
      typeof(self) strongSelf = weakSelf;
      [strongSelf endSendingDataInBackground];
    });
  }];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    typeof(self) strongSelf = weakSelf;
    
    [strongSelf setupTelemetryClientAndSendData];
  });
}

#pragma mark -

/**
 Begin the startup process
 */
- (void)startManager {
  if ([self isMetricsManagerDisabled]) return;
  
  MSAILog(@"INFO: Start MetricsManager");

//  [self registerObservers];
//  
//  [self loadMetricsTempData];
//  
//  [self startUsage];
//  
//  [self loadMetricsData];
//  
//  [self processLastSessionIfCrashed];
//
//  [self sendDataInBackground];
}

@end

#endif
