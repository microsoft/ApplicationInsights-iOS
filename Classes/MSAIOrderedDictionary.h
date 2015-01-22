#import <Foundation/Foundation.h>

@interface MSAIOrderedDictionary : NSMutableDictionary
{
    NSMutableDictionary *dictionary;
    NSMutableArray *order;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems;

- (void)setObject:(id)anObject forKey : (id)aKey;

@end
