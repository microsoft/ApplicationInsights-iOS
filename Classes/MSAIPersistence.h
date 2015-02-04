//
// Created by Benjamin Reimold on 03.02.15.
//

#import <Foundation/Foundation.h>


@interface MSAIPersistence : NSObject

+ (void)persistQueue:(NSArray *)queue;
+ (void)readPersistedQueue;

@end