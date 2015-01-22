//
//  orderedDictionary.m
//  orderedDictionary
//
//  Created by Crystal Maly on 1/16/15.
//  Copyright (c) 2015 Crystal Maly. All rights reserved.
//

#import "MSAIOrderedDictionary.h"

@implementation MSAIOrderedDictionary

- (instancetype)init {
    self = [super init];
    if ( self != nil )
    {
        dictionary = [NSMutableDictionary new];
        order = [NSMutableArray new];
    }
    return self;

}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
	self = [super init];
    if ( self != nil )
    {
        dictionary = [[NSMutableDictionary alloc] initWithCapacity:numItems];
        order = [NSMutableArray new];
    }
    return self;
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
    if(![dictionary objectForKey:aKey])
    {
        [order addObject:aKey];
    }
    [dictionary setObject:anObject forKey:aKey];
}

- (NSEnumerator *)keyEnumerator
{
    return [order objectEnumerator];
}

- (id)objectForKey:(id)key
{
    return [dictionary objectForKey:key];
}

- (NSUInteger)count
{
    return [dictionary count];
}


@end
