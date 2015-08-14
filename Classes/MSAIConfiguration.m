#import "MSAIConfiguration.h"
#import "MSAIHelper.h"

NSString * const serverURL = @"https://dc.services.visualstudio.com/v2/track";

// Debug
NSUInteger const MSAIMaxBatchCountDebug             = 5;
NSUInteger const MSAIMaxBatchIntervalDebug          = 3;
NSUInteger const MSAIBackgroundSessionIntervalDebug = 15;

// Live
NSUInteger const MSAIMaxBatchCount                  = 100;
NSUInteger const MSAIMaxBatchInterval               = 15;
NSUInteger const MSAIBackgroundSessionInterval      = 20;

@implementation MSAIConfiguration

@synthesize serverURL = _serverURL;
@synthesize maxBatchCount = _maxBatchCount;
@synthesize maxBatchInterval = _maxBatchInterval;
@synthesize backgroundSessionInterval = _backgroundSessionInterval;

-(instancetype)init{

  if(self = [super init]){
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

@end
