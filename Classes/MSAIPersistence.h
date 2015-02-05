//
// Created by Benjamin Reimold on 05.02.15.
//

#import <Foundation/Foundation.h>

@interface MSAIPersistence : NSObject

+ (void)persistBundle:(NSArray *)bundle;
+ (NSArray *)nextBundle;
+ (BOOL)deleteActiveBundle;

@end
