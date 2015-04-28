#import "ApplicationInsightsPrivate.h"
#import "MSAIObject.h"
#import "MSAIDomain.h"

@implementation MSAIObject

/// Not needed, since this is the base implementation of NSObject
- (instancetype)init {
  if (self = [super init]) {
    
  }
  return self;
}

// empty implementation for the base class
- (MSAIOrderedDictionary *)serializeToDictionary{
	MSAIOrderedDictionary *dict = [MSAIOrderedDictionary new];
	return dict;
}

- (NSString *)serializeToString {
  MSAIOrderedDictionary *dict = [self serializeToDictionary];
  NSMutableString  *jsonString;
  NSError *error = nil;
  NSData *json;
  json = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
  if (json == nil) {
    MSAILog(@"NSJSONSerialization error: %@", error.localizedDescription);
  }
  jsonString = [[NSMutableString alloc] initWithData:json encoding:NSUTF8StringEncoding];
  NSString *returnString = [[jsonString stringByReplacingOccurrencesOfString:@"\"true\"" withString:@"true"] stringByReplacingOccurrencesOfString:@"\"false\"" withString:@"false"];
  return returnString;
}

- (void)encodeWithCoder:(NSCoder *)coder {
}

- (id)initWithCoder:(NSCoder *)coder {
  return [super init];
}


@end
