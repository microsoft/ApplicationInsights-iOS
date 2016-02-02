#import "MSAIConfiguration.h"
#import "MSAIHelper.h"

NSString * const MSAIServerURL = @"https://dc.services.visualstudio.com/v2/track";

// Debug
NSUInteger const MSAIMaxBatchCountDebug             = 5;
NSUInteger const MSAIMaxBatchIntervalDebug          = 3;
NSUInteger const MSAIBackgroundSessionIntervalDebug = 15;

// Live
NSUInteger const MSAIMaxBatchCount                  = 100;
NSUInteger const MSAIMaxBatchInterval               = 15;
NSUInteger const MSAIBackgroundSessionInterval      = 20;

static char *const MSAIContextOperationsQueue = "com.microsoft.ApplicationInsights.ConfigurationQueue";

@implementation MSAIConfiguration

@synthesize serverURL = _serverURL;
@synthesize maxBatchCount = _maxBatchCount;
@synthesize maxBatchInterval = _maxBatchInterval;
@synthesize backgroundSessionInterval = _backgroundSessionInterval;

-(instancetype)init{

  if(self = [super init]){
    _operationsQueue = dispatch_queue_create(MSAIContextOperationsQueue, DISPATCH_QUEUE_CONCURRENT);
    
    _serverURL = [NSURL URLWithString:MSAIServerURL];
    if(msai_isDebuggerAttached()){
      _backgroundSessionInterval = MSAIBackgroundSessionIntervalDebug;
      _maxBatchInterval = MSAIMaxBatchIntervalDebug;
      _maxBatchCount = MSAIMaxBatchCountDebug;
    }else{
      _backgroundSessionInterval = MSAIBackgroundSessionInterval;
      _maxBatchInterval = MSAIMaxBatchInterval;
      _maxBatchCount = MSAIMaxBatchCount;
    }
  }
  return self;
}

- (NSURL *)serverURL {
  __block NSURL *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _serverURL;
  });
  return tmp;
}

- (void)setServerURL:(NSURL *)serverURL {
  NSURL* tmp = [serverURL copy];
  dispatch_barrier_async(_operationsQueue, ^{
    _serverURL = tmp;
  });
}

- (NSUInteger)maxBatchCount {
  __block NSUInteger *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _maxBatchCount;
  });
  return tmp;
}

- (void)setMaxBatchCount:(NSUInteger)maxBatchCount {
  dispatch_barrier_async(_operationsQueue, ^{
    _maxBatchCount = maxBatchCount;
  });
}

- (NSUInteger)maxBatchInterval {
  __block NSUInteger *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _maxBatchInterval;
  });
  return tmp;
}

- (void)setMaxBatchInterval:(NSUInteger)maxBatchInterval {
  dispatch_barrier_async(_operationsQueue, ^{
    _maxBatchInterval = maxBatchInterval;
  });
}

- (NSUInteger)backgroundSessionInterval {
  __block NSUInteger *tmp;
  dispatch_sync(_operationsQueue, ^{
    tmp = _backgroundSessionInterval;
  });
  return tmp;
}

- (void)setBackgroundSessionInterval:(NSUInteger)backgroundSessionInterval {
  dispatch_barrier_async(_operationsQueue, ^{
    _backgroundSessionInterval = backgroundSessionInterval;
  });
}

@end
