#import <Foundation/Foundation.h>
@class MSAIOrderedDictionary;

@interface MSAIObject : NSObject <NSCoding>

- (MSAIOrderedDictionary *)serializeToDictionary;
- (NSString *)serializeToString;

@end
