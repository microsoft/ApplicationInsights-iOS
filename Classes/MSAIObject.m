#import "ApplicationInsightsPrivate.h"
#import "MSAIObject.h"
#import "MSAIOrderedDictionary.h"

@implementation MSAIObject

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

- (instancetype)initWithCoder:(NSCoder *)coder {
  return [super init];
}


@end
