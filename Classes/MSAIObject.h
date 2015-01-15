#import <Foundation/Foundation.h>
#import "MSAIEnums.h"

@interface MSAIObject : NSObject

- (NSMutableDictionary *)serializeToDictionary;
- (NSString *)serializeToString;

@end
