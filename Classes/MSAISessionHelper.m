#import "AppInsightsPrivate.h"
#import "MSAISessionHelper.h"

static NSString *const kMSAIFileName = @"MSAISessions";
static NSString *const kMSAIFileType = @"plist";
static char *const MSAISessionOperationsQueue = "com.microsoft.appInsights.sessionQueue";

@interface MSAISessionHelper()

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) dispatch_queue_t operationsQueue;

@end

@implementation MSAISessionHelper

#pragma mark - Initialize

+ (id)sharedInstance {
  static MSAISessionHelper *sharedInstance = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [self new];
  });
  
  return sharedInstance;
}

- (instancetype)init {
  if(self = [super init]) {
    _operationsQueue = dispatch_queue_create(MSAISessionOperationsQueue, DISPATCH_QUEUE_SERIAL);
    _fileManager = [NSFileManager new];
    _filePath = [self createFilePath];
    [self createPropertyListIfNeeded];
  }
  return self;
}

#pragma mark - Helper

- (NSString *)createFilePath{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *fileName = [NSString stringWithFormat:@"%@.%@", kMSAIFileName, kMSAIFileType];
  return [documentsDirectory stringByAppendingPathComponent:fileName];
}

- (void)createPropertyListIfNeeded {
  if (_fileManager && _filePath && ![_fileManager fileExistsAtPath: _filePath]) {
    NSError *error;
    NSString *bundle = [[NSBundle mainBundle] pathForResource:kMSAIFileName ofType:kMSAIFileType]; //5
    [_fileManager copyItemAtPath:bundle toPath: _filePath error:&error];
    if(error){
      MSAILog(@"Could not create file %@.%@: %@", kMSAIFileName, kMSAIFileType, [error localizedDescription]);
    }
  }
}

@end
