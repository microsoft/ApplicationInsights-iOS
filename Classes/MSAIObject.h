#import <Foundation/Foundation.h>
#import "MSAIEnums.h"
#import "MSAIOrderedDictionary.h"

@interface MSAIObject : NSObject <NSCoding>

- (MSAIOrderedDictionary *)serializeToDictionary;
- (NSString *)serializeToString;

@end
