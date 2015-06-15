#import <Foundation/Foundation.h>
#import "MSAINullability.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSAIOrderedDictionary : NSMutableDictionary {
    NSMutableDictionary *dictionary;
    NSMutableArray *order;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems;
- (void)setObject:(id)anObject forKey:(id)aKey;

@end
NS_ASSUME_NONNULL_END
