#import "MSAICrashData.h"
#import "MSAICrashDataHeaders.h"
#import "MSAICrashDataBinary.h"
#import "MSAICrashDataThread.h"
#import "MSAIOrderedDictionary.h"

/// Data contract class for type CrashData.
@implementation MSAICrashData
@synthesize envelopeTypeName = _envelopeTypeName;
@synthesize dataTypeName = _dataTypeName;

/// Initializes a new instance of the class.
- (instancetype)init {
  if (self = [super init]) {
    _envelopeTypeName = @"Microsoft.ApplicationInsights.Crash";
    _dataTypeName = @"CrashData";
    self.version = @2;
    self.threads = [NSMutableArray new];
    self.binaries = [NSMutableArray new];
  }
  return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
  MSAIOrderedDictionary *dict = [super serializeToDictionary];
  MSAIOrderedDictionary *headersDict = [self.headers serializeToDictionary];
  if ([NSJSONSerialization isValidJSONObject:headersDict]) {
    [dict setObject:headersDict forKey:@"headers"];
  } else {
    NSLog(@"[ApplicationInsights] Some of the telemetry data was not NSJSONSerialization compatible and could not be serialized!");
  }
  if (self.threads != nil) {
    NSMutableArray *threadsArray = [NSMutableArray array];
    for (MSAICrashDataThread *threadsElement in self.threads) {
      [threadsArray addObject:[threadsElement serializeToDictionary]];
    }
    [dict setObject:threadsArray forKey:@"threads"];
  }
  if (self.binaries != nil) {
    NSMutableArray *binariesArray = [NSMutableArray array];
    for (MSAICrashDataBinary *binariesElement in self.binaries) {
      [binariesArray addObject:[binariesElement serializeToDictionary]];
    }
    [dict setObject:binariesArray forKey:@"binaries"];
  }
  return dict;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    self.headers = [coder decodeObjectForKey:@"self.headers"];
    self.threads = [coder decodeObjectForKey:@"self.threads"];
    self.binaries = [coder decodeObjectForKey:@"self.binaries"];
  }
  
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  [coder encodeObject:self.headers forKey:@"self.headers"];
  [coder encodeObject:self.threads forKey:@"self.threads"];
  [coder encodeObject:self.binaries forKey:@"self.binaries"];
}


@end
